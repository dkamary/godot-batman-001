extends State
## Un état de feu tricolore: une couleur, une durée, l'état suivant.

@export var color: Color = Color.GREEN
@export var duration: float = 2.0
@export var next: StringName = &"Orange"
var _t: float = 0.0

func enter(_previous: StringName, _data: Dictionary) -> void:
	_t = 0.0
	(owner.get_node("Lamp") as ColorRect).color = color
	print("%s -> %s" % [_previous, name])
	
func physics_update(_delta: float) -> void:
	_t += _delta
	if _t >= duration:
		transition_to(next)
