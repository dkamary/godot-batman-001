extends State			# version 1
## Saut et chute. Contrôle aérien total, saut à hauteur variable.
## Coup de pied sauté si un ennemi est à porté, sinon tir

@export var kick_duration : float = 0.25

@onready var p: Player = owner

var _kick_left : float = 0.0

func enter(_previous: StringName, _data: Dictionary) -> void:
	_kick_left = 0.0

func exit() -> void:
	p.melee_off()

func physics_update(_delta: float) -> void:
	# 1. Saut variable: relacher le bouton pendant la montée coupe l'élan.
	if Input.is_action_just_released("jump") and p.velocity.y < 0.0:
		p.velocity.y *= p.jump_cut
	p.apply_gravity(_delta)
	
	# 2. Saut retardé (coyote): on vient de quitter le bord.
	if p.wants_jump() and p.can_jump():
		p.jump()
		
	# 3.Contrôle aérien complet, typique des run & gun.
	p.run(p.read_move_x())
	
	# 4. Accroche sous un rebord: Maintenir "Haut" près du sommet du saut.
	if Input.is_action_pressed("move_up") and p.velocity.y > -60.0:
		var ledge_y : float = p.find_ledge()
		if not is_nan(ledge_y):
			transition_to(&"Hang", {"ledge_y": ledge_y})
			return
	
	# 5. Attaque.
	if _kick_left > 0.0:
		_kick_left -= _delta
		if _kick_left <= 0.0:
			p.melee_off()
	elif p.try_attack() == &"melee":
		_kick_left = kick_duration
		p.melee_on()
	
	# 6. Attérissage
	if p.is_on_floor() and p.velocity.y >= 0.0:
		transition_to(&"Run" if p.read_move_x() != 0.0 else &"Idle")
		return
	
	if _kick_left > 0.0:
		p.play_anim(&"kick")
	else:
		p.play_anim(&"jump" if p.velocity.y < 0.0 else &"fall")
