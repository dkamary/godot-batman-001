extends Node2D
## Cible d'entrainement: encaissem clignote, se répare.

@onready var health : Health = $Health
@onready var body : ColorRect = $ColorRect

func _ready() -> void:
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

func _on_damaged(amount: int) -> void:
	print("Cible: -%d (reste %d)" % [amount, health.current])
	body.color = Color.WHITE
	await  get_tree().create_timer(0.06).timeout
	body.color = Color(0.8, 0.2, 0.2)

func _on_died() -> void:
	print("Cible détruite: Réparation dans 1s")
	await get_tree().create_timer(1.0).timeout
	health.reset()
