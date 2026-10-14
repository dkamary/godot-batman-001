extends State			# version 1
## Accroupi: Esquive les tirs hauts et tire au ras du sol
## Bas + saut sur une plateforme transversable = descendre (hypothèse de confort)

@onready var p: Player = owner
@onready var body_shape : CollisionShape2D = owner.get_node("Body")
@onready var hurt_shape : CollisionShape2D = owner.get_node("Hurtbox/CollisionShape2D")
var _hurt_pos : Vector2 = Vector2.ZERO

func enter(_previous: StringName, _data: Dictionary) -> void:
	p.velocity.x = 0.0
	# On abaisse la zone de vulnérabilité: ce qui rend l'esquive réelle.
	_hurt_pos = hurt_shape.position
	hurt_shape.position.y += 10.0
	hurt_shape.scale.y = 0.6

func exit() -> void:
	hurt_shape.position = _hurt_pos
	hurt_shape.scale.y = 1.0

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
