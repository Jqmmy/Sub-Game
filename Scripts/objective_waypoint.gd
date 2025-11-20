extends Node3D

@onready var color_rect: ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var window = get_window()
	var screen_pos = get_viewport().get_camera_3d().unproject_position(global_position)
	var is_behind = get_viewport().get_camera_3d().is_position_behind(global_position)
	var is_in_frustrum = get_viewport().get_camera_3d().is_position_in_frustum(global_position)
	if is_behind:
		if screen_pos.x > window.size.x / 2:
			color_rect.position.x = 0
		else:
			color_rect.position.x = window.size.x - 40
		
		color_rect.position.y = screen_pos.y
		color_rect.position.y = clampf(color_rect.position.y, 0, window.size.y - 40)
	elif not is_in_frustrum:
		color_rect.position.y = screen_pos.y
		color_rect.position.x = screen_pos.x
		color_rect.position.x = clampf(color_rect.position.x, 0, window.size.x - 40)
		color_rect.position.y = clampf(color_rect.position.y, 0, window.size.y - 40)
	else:
		color_rect.position = screen_pos
	
	
	
