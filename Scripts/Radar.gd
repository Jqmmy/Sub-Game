@tool
extends Control

@export var arc_width:float = 1.571:
	set(value):
		arc_width = value
		queue_redraw()
@export var arc_position:float = 0:
	set(value):
		arc_position = value - 1.5707963267948966
		queue_redraw()

 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		queue_redraw()

func _draw() -> void:
	draw_circle(size/2, 100, Color.WHITE, true)
	draw_circle(size/2, 100, Color.GRAY, false, 10.0, false)
	draw_arc(size/2, 100, arc_position - arc_width, arc_position + arc_width, 50,  Color.RED, 10.0)
