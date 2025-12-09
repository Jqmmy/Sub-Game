class_name Hud
extends Control

@onready var hover_text_label: Label = $"hover labels/hover text"
@onready var button_text_label: Label = $"hover labels/button text"

func add_hover_text(hover_text:String, button_text:String = ""):
	hover_text_label.text = hover_text
	button_text_label.text = button_text

func _draw() -> void:
	draw_circle(size/2, 3, Color.WHITE)
	
