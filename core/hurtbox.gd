class_name Hurtbox
extends Area2D
## Zone vulnérable. Ne détecte rien d'elle-même : ce sont les Hitbox qui la trouvent.

signal hurt(hitbox: Hitbox)

@export var health: Health
var invincible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	monitoring = false	# Une hurtbox est "vue", elle ne regarde pas

func take_hit(hitbox: Hitbox) -> bool:
	## Renvoie true si le coup a porté
	if invincible or (health != null and health.is_dead()):
		return false
	if health != null:
		health.damage(hitbox.damage)
	hurt.emit(hitbox)
	return true
