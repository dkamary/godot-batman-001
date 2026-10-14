extends State 			# version 1

@onready var p: Player = owner

func physics_update(_delta: float) -> void:
	p.apply_gravity(_delta)
	if not p.is_on_floor():
		transition_to(&"Air")
		return
	var x: float = p.read_move_x();
	if x == 0.0:
		transition_to(&"Idle")
		return
	if p.wants_jump() and p.can_jump():
		p.jump()
		transition_to(&"Air")
		return
	if p.try_attack() == &"melee":
		transition_to(&"Melee")
		return
	p.run(x)
	p.play_anim(&"run")
