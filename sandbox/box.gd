extends Node2D
# Mon premier script: un carré qui se déplace avec les flèches

@export var speed :float = 120.0 #pixel par seconde, modifiable dans l'inspecteur
@export var color_period :float = 1.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	print("Bonjour depuis ", name)
	timer.wait_time = color_period
	
func _physics_process(delta: float) -> void:
	var dir :Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += dir * speed * delta
	position = position.clamp(Vector2.ZERO, Vector2(320, 224))


func _on_timer_timeout() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())
