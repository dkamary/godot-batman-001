@tool
extends EditorScript
## Crée les actions d'entrée du projet. À exécuter une seule fois (Fichier > Exécuter)
## Puis Projet > Recharger le projet en cours.

func _run() -> void:
	var actions : Dictionary = {
		"move_left": [_key(KEY_LEFT), _key(KEY_A), _pad(JOY_BUTTON_DPAD_LEFT), _axis(JOY_AXIS_LEFT_X, -1.0)],
		"move_right": [_key(KEY_RIGHT), _key(KEY_D), _pad(JOY_BUTTON_DPAD_RIGHT), _axis(JOY_AXIS_LEFT_X, 1.0)],
		"move_up": [_key(KEY_UP), _key(KEY_W), _pad(JOY_BUTTON_DPAD_UP), _axis(JOY_AXIS_LEFT_Y, -1.0)],
		"move_down": [_key(KEY_DOWN), _key(KEY_S), _pad(JOY_BUTTON_DPAD_DOWN), _axis(JOY_AXIS_LEFT_Y, 1.0)],
		"attack": [_key(KEY_J), _key(KEY_L), _pad(JOY_BUTTON_X), _pad(JOY_BUTTON_B)],
		"jump": [_key(KEY_K), _key(KEY_SPACE), _pad(JOY_BUTTON_A)],
		"start": [_key(KEY_ENTER), _pad(JOY_BUTTON_START)],
	}
	for action_name: String in actions:
		ProjectSettings.set_setting("input/" + action_name, {
			"deadzone": 0.4,
			"events": actions[action_name]
		})
	ProjectSettings.save()
	print("Actions créées : ", actions.keys())

func _key(code: Key) -> InputEventKey:
	var e := InputEventKey.new()
	e.physical_keycode = code
	return e

func _pad(button: JoyButton) -> InputEventJoypadButton:
	var e := InputEventJoypadButton.new()
	e.button_index = button
	return e
	
func _axis(axis: JoyAxis, value: float) -> InputEventJoypadMotion:
	var e := InputEventJoypadMotion.new()
	e.axis = axis
	e.axis_value = value
	return e
