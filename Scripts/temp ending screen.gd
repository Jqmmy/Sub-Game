extends Control

const MAIN_MENU = preload("uid://btbsnk4tbdk0k")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)
