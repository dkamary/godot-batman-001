extends State
## Recul après un coup : pas de controle pendant le hurt_time

@onready var p : Player = owner
var _t : float = 0.0

func enter(_previous: StringName, _data: Dictionary) -> void:
	_t = 0.0
	p.melee_off()
	p.play_anim(&"hurt")

func physics_update(_delta: float) -> void:
	_t += _delta
	p.apply_gravity(_delta)
	p.velocity.x = move_toward(p.velocity.x, 0.0, 600 * _delta)
	if _t < p.hurt_time:
		return
	transition_to(&"Idle" if p.is_on_floor() else &"Air")
