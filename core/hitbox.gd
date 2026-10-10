class_name Hitbox
extends Area2D
## Zone qui inflige des dégats aux Hurtbox présentes dans son masque de collision

signal landed(hurtbox: Hurtbox)

@export var damage: int = 1

## Poussées appliquée à la cible (x orienté vers l'avant de l'attaquant)
@export var knockback : Vector2 = Vector2(120, -80)

## Pour un projectile: se désactive après le premier impact
@export var single_hit: bool = false

## Sens de l'attaquant: 1 vers la doite, -1 ver la gauche (mis à jour par le porteur)
var facing: int = 1

var _already_hit: Array[Hurtbox] = []

func _ready() -> void:
	monitorable = false # personne n'a besoin de voir une hitbox
	area_entered.connect(_on_area_entered)
	
func reset_hits() -> void:
	_already_hit.clear()
	
func _on_area_entered(area: Area2D) -> void:
	var hurtbox : Hurtbox = area as Hurtbox
	if hurtbox == null or hurtbox in _already_hit:
		return
	_already_hit.append(hurtbox)
	if hurtbox.take_hit(self):
		landed.emit(hurtbox)
		if single_hit:
			set_deferred("monitoring", false)

func get_knockback() -> Vector2:
	return Vector2(knockback.x * facing, knockback.y)
