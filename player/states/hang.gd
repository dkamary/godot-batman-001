extends State
## Suspendu au rebord. Saut = grimper ; bas + saut = se laisser tomber.
## On peut tirer devant, en diagonal basse et vers le bas

@export var hang_offset : float = 44.0
@onready var p : Player = owner
var _ledge_y : float = 0.0

func enter(_previous: StringName, _data: Dictionary) -> void:
	_ledge_y = _data.get("ledge_y", p.global_position.y)
	p.velocity = Vector2.ZERO
	p.global_position.y = _ledge_y + hang_offset

func physics_update(_delta: float) -> void:
	p.velocity = Vector2.ZERO
	if p.wants_jump():
		p.consume_jump()
		if Input.is_action_pressed("move_down"):
			transition_to(&"Air")		# On lache
		else:
			# Grimper: On pose les pieds juste au-dessus du rebord.
			p.global_position.y = _ledge_y - 1.0
			transition_to(&"Air")		# Air détecte le sol au tick suivant et passe en Idle
		return
	var dir : float  = p.read_move_x()
	if dir != 0.0:
		p.set_facing(int(signf(dir)))
	p.try_attack(false, false)			# Pas de tir vers le haut à travers le balcon
	p.play_anim(&"hang")
