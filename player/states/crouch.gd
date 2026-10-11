extends State			# version 1
## Accroupi: Esquive les tirs hauts et tire au ras du sol
## Bas + saut sur une plateforme transversable = descendre (hypothèse de confort)

@onready var p: Player = owner

func enter(_previous: StringName, _data: Dictionary) -> void:
	p.velocity.x = 0.0

func physics_update(_delta: float) -> void:
	p.apply_gravity(_delta)
	p.velocity.x = 0.0
	if not p.is_on_floor():
		transition_to(&"Air")
		return
	if p.wants_jump():
		p.consume_jump()
		p.drop_through_platform()
		transition_to(&"Air")
		return
	if not Input.is_action_pressed("move_down"):
		transition_to(&"Idle")
		return
	var dir: float = p.read_move_x()
	if dir != 0.0:
		p.set_facing(int(signf(dir)))
	p.play_anim(&"crouch")
