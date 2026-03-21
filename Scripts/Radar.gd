@tool
extends Control

@export var arc_width:float = 1.571:
	set(value):
		arc_width = value
		queue_redraw()
@export var arc_position:float = 0:
	set(value):
		arc_position = value - 1.571
		queue_redraw()
@export var circle_size:float = 100:
	set(value):
		circle_size = value
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		queue_redraw()

func _draw() -> void:
	#draw_circle(size/2, circle_size, Color.WHITE, true)
	draw_arc(size/2, circle_size / 2, arc_position - arc_width, arc_position + arc_width, 50, Color(0.0, 0.392, 0.0, 0.451), circle_size + 10)
	draw_circle(size/2, 10, Color.WEB_GREEN, true, -1, false)
	draw_circle(size/2, circle_size, Color.WEB_GREEN, false, 10.0, false)
