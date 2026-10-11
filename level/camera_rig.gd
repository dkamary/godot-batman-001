class_name CameraRig
extends Camera2D
## Camera de run & gun: suit le joueur avec anticipation, ne reviens jamais en arrière
## peut être verrouillée sur une arène ou défiler toute seule (convoi).

@export var target: Player
@export var look_ahead: float = 40.0		## px d'avance dans la direction du regard
@export var follow_rate: float = 5.0		## plus grand = rattrapage plus rapide
@export var forward_only: bool = true		## l'écran ne recule pas
@export var fixed_y: float = 112.0			## section du niveau 1 ne défile pas verticalement

## px/s: défilement forcé de l'écran, Non utilisé dans le niveau 1 (au convoi, c'est la rue
## qui défile derrière un convoi immobile, tome 09), mais prêt pour un niveau à défilement imposé.
var autoscroll_speed: float = 0.0
var _locked: bool = false
var _lock_center_x: float = 0.0

func _ready() -> void:
	make_current()
	if target:
		target.camera = self
		global_position = Vector2(target.global_position.x, fixed_y)

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var x: float = global_position.x
	if _locked:
		x = move_toward(x, _lock_center_x, 240 * delta)
	else:
		var desired: float = target.global_position.x + look_ahead * target.facing
		# Lissage exponentiel indépendant du nombre d'images par seconde.
		var t: float = 1.0 - exp(-follow_rate * delta)
		var next: float = lerpf(x, desired, t) + autoscroll_speed * delta
		x = maxf(next, x) if forward_only else next
	global_position = Vector2(x, fixed_y)

func lock_on(center_x: float) -> void:
	_locked = true
	_lock_center_x = center_x

func unlock() -> void:
	_locked = false
	
func view_rect() -> Rect2:
	var size := get_viewport_rect().size / zoom
	return Rect2(global_position - size / 2.0, size)

func clamp_to_view(body: Node2D, margin: float = 20.0) -> void:
	var r: Rect2 = view_rect()
	body.global_position.x = clampf(body.global_position.x, r.position.x + margin, r.end.x - margin)
