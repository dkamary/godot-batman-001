class_name StateMachine
extends Node
## Gère des états enfants. Le propriétaire appelle physics_update() depuis son _physics_process

signal state_changed(previous: StringName, current: StringName)

@export var initial_state: State
var state: State
var _states: Dictionary = {} # StringName -> State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is State:
			_states[child.name] = child
			child.finished.connect(_on_state_finished)
	if initial_state == null and get_child_count() > 0:
		initial_state = get_child(0) as State
		
	# On attend que le propriétaire soit prêt (ses @onready sont résolus après nous
	await  owner.ready
	state = initial_state
	state.enter(&"", {})

func physics_update(delta: float) -> void:
	if state:
		state.physics_update(delta)

func update(delta: float) -> void:
	if state:
		state.update(delta)

func force(next_state: StringName, data: Dictionary = {}) -> void:
	## Transition imposée de l'exterieur (dégâts, mort, cinématique).
	_on_state_finished(next_state, data)

func current_name() -> StringName:
	return state.name if state else &""

func _on_state_finished(next_state: StringName, data: Dictionary) -> void:
	if not _states.has(next_state):
		push_error("État inconnu: %s" % next_state)
		return
	var previous: StringName = state.name if State else &""
	if state:
		state.exit()
	state = _states[next_state]
	state.enter(previous, data)
	state_changed.emit(previous, next_state)
