extends Node2D
## Banc d'essai: un point qui traverse une cible en boucle

@onready var fist: Node2D = $Fist
@onready var health: Health = $Target/Health

func _ready() -> void:
	health.damaged.connect(func(a: int) -> void: print("Touché ! -", a, " -> reste ", health.current))
	health.died.connect(func() -> void: print("Cible détruite!"))

func _physics_process(delta: float) -> void:
	fist.position.x += 80.0 * delta
	if fist.position.x > 300.0:
		fist.position.x = 20.0
		$Fist/Hitbox.reset_hits()
