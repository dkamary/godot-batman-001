extends Node2D
## Salle de test: réapparition après la mort et raccourcis de déboggage

@onready var player : Player = $Player

func _ready() -> void:
	print("Test Room ready!!!")
	player.died.connect(player.respawn)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		# Simule une empoignade: la salle joue le rôle du costaud.
		player.fsm.force(&"Grabbed", {"grabber" : self})
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_V:
				player.celebrate()
			KEY_I:
				player.fsm.force(&"Idle")
