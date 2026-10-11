class_name Player
extends CharacterBody2D
## Batman ou Robin. Les décisions sont prises par les états (stateMachine);
## ce script port eles réglages et les actions communes

@export_group("Déplacements")
@export var run_speed: float = 117.0
@export var jump_velocity: float = -330.0
@export var gravity: float = 900.0
@export var max_fall_speed : float = 330.0
@export_range(0.0, 0.1) var jump_cut: float = 0.45
@export var coyote_time: float = 0.06				## tolérance moderne; 0 = comportement strict
@export var jump_buffer: float = 0.10

var facing: int = 1
var camera: CameraRig
var _coyote: float = 0.0
var _buffer: float = 0.0
var _drop_left : float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var fsm: StateMachine = $StateMachine

func _physics_process(delta: float) -> void:
	_coyote = coyote_time if is_on_floor() else maxf(_coyote - delta, 0.0)
	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer
	else:
		_buffer = maxf(_buffer - delta, 0.0)
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

func play_anim(base: StringName) -> void:
	if sprite.sprite_frames == null:
		return
	if sprite.sprite_frames.has_animation(base) and sprite.animation != base:
		sprite.play(base)
