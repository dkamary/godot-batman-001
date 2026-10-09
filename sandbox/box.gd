extends Node2D
# Mon premier script: un carré qui se déplace avec les flèches

@export var speed :float = 120.0 #pixel par seconde, modifiable dans l'inspecteur

func _ready() -> void:
	print("Bonjour depuis ", name)
	
func _process(delta: float) -> void:
	var dir :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += dir * speed * delta


func _on_timer_timeout() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())
