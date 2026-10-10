class_name Health
extends Node
## Points de vie générique: Joueurs, Enemis et Boss

signal changed(current: int, maximum: int)
signal damaged(amount: int)
signal died

@export var max_health: int = 8
var current: int = 0
var invincible: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current = max_health

func is_dead() -> bool:
	return current <= 0
	
func damage(amount: int) -> void:
	if invincible or is_dead() or amount <= 0:
		return
	
	current = maxi(current - amount, 0)
	damaged.emit(amount)
	changed.emit(current, max_health)
	if (current == 0):
		died.emit()
		
func heal(amount: int) -> void:
	if is_dead():
		return
	current = mini(current + amount, max_health)
	changed.emit(current, max_health)
	
func reset() -> void:
	current = max_health
	changed.emit(current, max_health)
