extends CharacterBody2D
## Prototype jettable : tout dans un seul script pour sentir le personnage

@export var run_speed: float = 117.0				## px/s mesuré: 1.95px/image
@export var jump_velocity : float = -330.0			## px/s ver le haut (y négatif = vers le haut)
@export var gravity: float = 900.0					## px/s²
@export var max_fall_speed: float = 330.0
@export_range(0.0, 1.0) var jump_cut := 0.45		## part de vitesse gardée si on relache tôt

var is_crouching: bool = false

func _physics_process(delta: float) -> void:
	# 1. Gravité: La vitesse verticale augment à chaque tick, plafonnée.
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	
	is_crouching = is_on_floor() and Input.is_action_pressed("move_down")
	$Placeholder.size.y = 22.0 if is_crouching else 36.0
	$Placeholder.position.y = -22.0 if is_crouching else -36.0
	
	# 2. Course: démarrage et arrêt secs, comme dans le jeu original.
	var x: float = Input.get_axis("move_left", "move_right")
	if is_crouching:
		velocity.x = 0.0
	else:
		velocity.x = signf(x) * run_speed
	
	# 3. Saut, seulement depuis le sol.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	# Saut variable: relâcher pendant la montée coupe l'élan.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut
		
	# 4. Le moteur déplace le corps selon la velocity et gère les collisions
	move_and_slide()
