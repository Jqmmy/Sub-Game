extends Node

var sens = 0.005
var controller_sens:float = 0.001
var current_control:control = control.KEYBOARD
enum control {
	KEYBOARD,
	CONTROLLER
}

func _enter_tree():
	pass
	# Wait a frame to be rendered before restoring the window properties.
	# Otherwise, properties will be restored too early and the window border
	# will show up around a transparent window.
	#await get_tree().process_frame
#
	#get_viewport().transparent_bg = false
	#get_window().transparent = false
	#get_window().borderless = false
	#get_window().size = Vector2i(1152, 648)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse or event is InputEventAction:
		current_control = control.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventMouse:
		if event is InputEventJoypadMotion:
			if event.axis_value > 0.5:
				current_control = control.CONTROLLER
		if InputEventAction:
			current_control = control.CONTROLLER
