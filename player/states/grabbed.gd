extends State
## Empoigné par un costaud (tome 05). Marteler les boutons pour se dégager.

@export var escape_presses := 6
@onready var p: Player = owner
var _presses := 0
var _grabber: Node2D


func enter(_previous: StringName, data: Dictionary) -> void:
	_grabber = data.get("grabber")
	_presses = 0
	p.velocity = Vector2.ZERO
	p.melee_off()
	p.play_anim(&"grabbed")


func physics_update(_delta: float) -> void:
	p.velocity = Vector2.ZERO
	for action in ["attack", "jump", "move_left", "move_right"]:
		if Input.is_action_just_pressed(action):
			_presses += 1
	if _presses >= escape_presses or not is_instance_valid(_grabber):
		if is_instance_valid(_grabber) and _grabber.has_method("release"):
			_grabber.release()
		p.velocity = Vector2(-p.facing * 120.0, -150.0)
		p.start_invincibility(0.8)
		transition_to(&"Air")
