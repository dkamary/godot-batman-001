extends State
## Pose de victoire après un boss: cape fermée, immobile

@onready var p : Player = owner

func enter(_previous: StringName, _data: Dictionary) -> void:
	p.melee_off()
	p.hurtbox.invincible = true
	p.velocity.x = 0.0
	p.play_anim("victory")

func physics_update(_delta: float) -> void:
	p.apply_gravity(_delta)
	p.velocity.x = 0.0
