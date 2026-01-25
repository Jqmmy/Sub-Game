extends Node

var sens = 0.005
var controller_sens:float = 0.05
var current_control:control = control.KEYBOARD
enum control {
	KEYBOARD,
	CONTROLLER
}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse or event is InputEventAction:
		current_control = control.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventMouse:
		if event is InputEventJoypadMotion:
			if event.axis_value > 0.5:
				current_control = control.CONTROLLER
		if InputEventAction:
			current_control = control.CONTROLLER
