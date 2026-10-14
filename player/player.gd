class_name Player
extends CharacterBody2D
## Batman ou Robin. Les décisions sont prises par les états (stateMachine);
## ce script port eles réglages et les actions communes

signal died ## émis quand l'animation de mort est terminée

@export var hero : HeroData

@export_group("Déplacements")
@export var run_speed : float = 117.0				## px/s, mesuré: ~1,95 px / image
@export var jump_velocity : float = -330.0			## px/s, À CALIBRER (sommet = 60px avec gravity = 900)
@export var gravity : float = 900.0
@export var max_fall_speed : float = 330.0
@export_range(0.0, 0.1) var jump_cut : float = 0.45	## saut variable: part de vitesse gardée au relachement, À CALIBRER
@export var coyote_time : float = 0.06				## tolérance moderne; 0 = comportement strict
@export var jump_buffer : float = 0.10

@export_group("Combat")
@export var invicibility_time : float = 1.5
@export var hurt_time : float = 0.35

## Fiches des hérosm dans l'ordre de l'enum Game.Hero (BATMAN, ROBIN).
const HERO_FILES : Array = ["res://player/batman.tres", "res://player/robin.tres"]

## Position du canon selon la visée (droite = +x). Clé : (|x| > 0, signe de y).
const MUZZLES : Dictionary = {
	Vector2i(1, 0): Vector2(14, -24),
	Vector2i(1, -1): Vector2(12, -36),
	Vector2i(0, -1): Vector2(2, -44),
	Vector2i(1, 1): Vector2(12, -12),
	Vector2i(0, 1): Vector2(0, -6),
}

var facing : int = 1
var aim : Vector2 = Vector2.RIGHT
var camera : CameraRig
var _coyote : float = 0.0
var _buffer : float = 0.0
var _invicible_left : float = 0.0
var _shoot_pose : float = 0.0
var _drop_left : float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health: Health = $Health
@onready var hurtbox : Hurtbox = $Hurtbox
@onready var melee_hitbox : Hitbox = $MeleeHitbox
@onready var melee_sense : Area2D = $MeleeSense
@onready var hand_probe : Area2D = $HandProbe
@onready var fsm: StateMachine = $StateMachine
## Non typé: Le weapon system n'arrive qu'au tome 4. Sans lui, Batman ne tire pas.
@onready var weapons: Node = get_node_or_null("WeaponSystem")

func _ready() -> void:
	if hero == null:
		hero = load(HERO_FILES[Game.hero]) as HeroData		# Choix de l'écran PLAYER SELECT
	if hero:
		sprite.sprite_frames = hero.frames
		run_speed = hero.run_speed
		jump_velocity = hero.jump_velocity
	melee_hitbox.monitoring = false
	hurtbox.hurt.connect(_on_hurt)
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	_coyote = coyote_time if is_on_floor() else maxf(_coyote - delta, 0.0)
	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer
	else:
		_buffer = maxf(_buffer - delta, 0.0)
	_shoot_pose = maxf(_shoot_pose - delta, 0.0)
	_tick_invincibility(delta)
	if _drop_left > 0.0:
		_drop_left -= delta
		if _drop_left <= 0.0:
			set_collision_layer_value(2, true)
	fsm.physics_update(delta)
	move_and_slide()
	if camera:
		camera.clamp_to_view(self)
	
func apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

func read_move_x() -> float:
	return Input.get_axis("move_left", "move_right")
	
func run(dir_x: float) -> void:
	velocity.x = signf(dir_x) * run_speed
	if dir_x != 0.0:
		set_facing(int(signf(dir_x)))

func set_facing(dir: int) -> void:
	if dir == 0 or dir == facing:
		return
	facing = dir
	sprite.flip_h = facing < 0
	melee_hitbox.scale.x = facing
	melee_sense.scale.x = facing
	melee_hitbox.facing = facing

func wants_jump() -> bool:
	return _buffer > 0.0

func can_jump() -> bool:
	return is_on_floor() or _coyote > 0.0

func consume_jump() -> void:
	_buffer = 0.0
	_coyote = 0.0

func jump() -> void:
	velocity.y = jump_velocity
	consume_jump()

func drop_through_platform() -> void:
	## Bas + saut sur le balcon : on ignore la couche platform un instant
	set_collision_mask_value(2, false)
	position.y += 2.0
	_drop_left = 0.25

func find_ledge() -> float:
	## Renvoie la hauteur du rebord touché par les mains ou NAN
	for area in hand_probe.get_overlapping_areas():
		return area.global_position.y
	return NAN

# --- COMBAT -------
func compute_aim(crouching : bool = false) -> Vector2:
	var x : float = signf(read_move_x())
	var y : float = signf(Input.get_axis("move_up", "move_down"))
	if crouching or (is_on_floor() and y > 0.0):
		y = 0.0		# au sol, "bas" veut dire s'accroupir, pas viser ses pieds
	if x == 0.0 and y == 0.0:
		x = facing
	aim = Vector2(x, y).normalized()
	return aim

func enemy_in_reach() -> bool:
	return melee_sense.has_overlapping_areas()

## Bouton d'attaque. Renvoie &"melee" si l'état doit jouer un coup au contact.
func try_attack(crouching : bool = false, allow_up : bool = true) -> StringName:
	if not Input.is_action_pressed("attack"):
		return &""
	aim = compute_aim(crouching)
	if not allow_up and aim.y < 0.0:
		aim = Vector2(facing, 0.0)
	if Input.is_action_just_pressed("attack") and enemy_in_reach() and aim.y == 0.0:
		return &"melee"
	if weapons and weapons.try_fire(muzzle_position(crouching), aim):
		_shoot_pose = 0.15
	return &""

func muzzle_position(crouching : bool = false) -> Vector2:
	var key : Vector2i = Vector2i(1 if abs(aim.x) > 0.1 else 0, int(signf(aim.y)))
	var offset : Vector2 = MUZZLES.get(key, MUZZLES[Vector2i(1, 0)])
	if crouching:
		offset.y += 12.0
	offset.x *= facing
	return global_position + offset

func melee_on() -> void:
	melee_hitbox.reset_hits()
	melee_hitbox.set_deferred("monitoring", true)

func melee_off() -> void:
	melee_hitbox.set_deferred("monitoring", false)

func start_invincibility(duration : float) -> void:
	_invicible_left = duration
	hurtbox.invincible = true

func _tick_invincibility(delta : float) -> void:
	if _invicible_left <= 0.0:
		return
	_invicible_left -= delta
	# Clignotement "Une image sur deux", typique de la Mega Drive.
	sprite.visible = int(_invicible_left * 30.0) % 2 == 0
	if _invicible_left <= 0.0:
		hurtbox.invincible = false
		sprite.visible = true

func _on_hurt(hitbox: Hitbox) -> void:
	if health.is_dead():
		return
	velocity = hitbox.get_knockback()
	start_invincibility(invicibility_time)
	fsm.force(&"Hurt")

func _on_died() -> void:
	fsm.force(&"Dead")

func respawn() -> void:
	## Réapparition: Batman tombe du haut de l'écran, comme dans les run & gun d'arcade
	health.reset()
	sprite.visible = true
	if camera:
		var view = camera.view_rect()
		global_position = Vector2(view.position.x + view.size.x * 0.35, view.position.y + 24.0)
	velocity = Vector2.ZERO
	start_invincibility(2.5)
	fsm.force(&"Air")

func celebrate() -> void:
	fsm.force(&"Victory")

func play_anim(base: StringName) -> void:
	if sprite.sprite_frames == null:
		return
	var anim : StringName = base
	if _shoot_pose > 0.0:
		var shoot: StringName = StringName("%s_shoot_%s" % [base, _aim_suffix()])
		if sprite.sprite_frames.has_animation(shoot):
			anim = shoot
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)

func _aim_suffix() -> String:
	if aim.y < -0.1:
		return "up" if absf(aim.x) < 0.1 else "diag_up"
	if aim.y > 0.1:
		return "down" if absf(aim.x) < 0.1 else "diag_down"
	return "fwd"
