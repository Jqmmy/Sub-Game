extends Node

var sens = 0.005
var controller_sens:float = 0.01
var current_control:control = control.KEYBOARD
enum control {
	KEYBOARD,
	CONTROLLER
}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse or event is InputEventKey:
		current_control = control.KEYBOARD
	if event is InputEventJoypadMotion:
		if event.axis_value > 0.5:
			current_control = control.CONTROLLER
	if event is InputEventJoypadButton:
		current_control = control.CONTROLLER
