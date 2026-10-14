extends State
## Animation de mort, puis signal « died » : la section décide (réapparition ou game over).

@export var duration := 2.0
@onready var p: Player = owner
var _t := 0.0
var _reported := false


func enter(_previous: StringName, _data: Dictionary) -> void:
	_t = 0.0
	_reported = false
	p.melee_off()
	p.hurtbox.invincible = true
	p.velocity = Vector2(-p.facing * 60.0, -200.0)
	p.play_anim(&"dead")


func physics_update(delta: float) -> void:
	p.apply_gravity(delta)
	if p.is_on_floor():
		p.velocity.x = 0.0
	_t += delta
	if _t >= duration and not _reported:
		_reported = true
		p.died.emit()
