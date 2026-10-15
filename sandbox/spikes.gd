extends Hitbox
## Piège de test: blesse à chaque nouveau contact.

func _ready() -> void:
	super._ready()			# garde le comportement de Hitbox (monitorable = false, connexion, ...)
	# Quand Batman sort du piègem il pourra être retouché à nouveau en y revenant.
	area_exited.connect(func(a: Area2D) -> void: _already_hit.erase(a))
