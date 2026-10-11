extends Node2D
## Le propriétaire fait avancer la machine à état à chaque tick.

@onready var fsm: StateMachine = $StateMachine

func _physics_process(delta: float) -> void:
	fsm.physics_update(delta)
