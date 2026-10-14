extends State
## Coup au contact. La Hitbox n'est active que sur les images "Actives" du coup.

@export var duration : float = 0.24
@export var active_from : float = 0.05
@export var active_to : float = 0.16
@export var combo_window : float = 0.35			## délai pour enchainer poing puis pied

@onready var p : Player = owner
var _t : float = 0.0
var _active : bool = false
var _combo : int = 0
var _last_end_ms : int = -100000

func enter(_previous: StringName, _data: Dictionary) -> void:
	_t = 0.0
	_active = false
	p.velocity.x = 0.0
	var since_last : float = (Time.get_ticks_msec() - _last_end_ms) / 1000.0
	_combo = (_combo + 1) % 2 if since_last < combo_window else 0
	p.play_anim(&"punch" if _combo == 0 else &"kick")

func exit() -> void:
	p.melee_off()
	_last_end_ms = Time.get_ticks_msec()

func physics_update(_delta: float) -> void:
	p.apply_gravity(_delta)
	p.velocity.x = 0.0
	_t += _delta
	var should_be_active : bool = _t >= active_from and _t < active_to
	if should_be_active != _active:
		_active = should_be_active
		if _active:
			p.melee_on()
		else:
			p.melee_off()
	if _t >= duration:
		transition_to(&"Idle")
