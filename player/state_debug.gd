extends Label
## Outil de débogage: affiche l'état courant et le sens du regard au dessus du personnage.

@export var player: Player

func _process(delta: float) -> void:
	text = "%s %s" % [player.fsm.current_name(), "->" if player.facing > 0 else "<-"]
