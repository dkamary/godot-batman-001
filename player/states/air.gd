extends State			# version 1
## Saut et chute. Contrôle aérien total, saut à hauteur variable.

@onready var p: Player = owner

func physics_update(_delta: float) -> void:
	# 1. Saut variable: relacher le bouton pendant la montée coupe l'élan.
	if Input.is_action_just_released("jump"):
		p.velocity.y *= p.jump_cut
	p.apply_gravity(_delta)
	
	# 2. Saut retardé (coyote): on vient de quitter le bord.
	if p.wants_jump() and p.can_jump():
		p.jump()
		
	# 3.Contrôle aérien complet, typique des run & gun.
	p.run(p.read_move_x())
	
	# 4. Attérissage
	if p.is_on_floor() and p.velocity.y >= 0.0:
		transition_to(&"Run" if p.read_move_x() != 0.0 else &"Idle")
		return
		
	p.play_anim(&"jump" if p.velocity.y < 0.0 else &"fall")
