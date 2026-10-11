class_name State
extends Node
## Classe de base d'un état. Les états concrets surchargent les fonctions utiles.

## Émis pour demander une transition. Toujours émis via transition_to()
signal finished(next_state: StringName, data: Dictionary)

func enter(_previous: StringName, _data: Dictionary) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func transition_to(next_state: StringName, data: Dictionary = {}) -> void:
	finished.emit(next_state, data)
