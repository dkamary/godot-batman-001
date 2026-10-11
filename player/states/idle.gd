extends State			# Version 1

@onready var p: Player = owner

func enter(_previous: StringName, _data: Dictionary) -> void:
	p.velocity.x = 0.0

func physics_update(_delta: float) -> void:
	p.apply_gravity(_delta)
	if not p.is_on_floor():
		transition_to(&"Air")
		return
	if Input.is_action_pressed("move_down"):
		transition_to(&"Crouch")
		return
	if p.wants_jump() and p.can_jump():
		p.jump()
		transition_to(&"Air")
		return
	if p.read_move_x() != 0.0:
		transition_to(&"Run")
		return
	p.velocity.x = 0.0
	p.play_anim(&"idle")
