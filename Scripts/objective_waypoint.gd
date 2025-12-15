class_name Waypoint extends Node3D

@export var use_last_scan_position:bool = false
var last_scan_position:Vector3

@export var active:bool = false:
	set(value):
		active = value
		last_scan_position = global_position
		if active:
			color_rect.show()
		else:
			color_rect.hide()
@export var edge_padding:float = 20

@onready var color_rect: ColorRect = $ColorRect

func _process(_delta: float) -> void:
	if active:
		var scan_pos:Vector3
		if use_last_scan_position:
			scan_pos = last_scan_position
		else:
			scan_pos = global_position
		
		var screen_pos = get_viewport().get_camera_3d().unproject_position(scan_pos)
		var is_in_frustrum = get_viewport().get_camera_3d().is_position_in_frustum(scan_pos)
		if is_in_frustrum:
			color_rect.position = screen_pos
			return
		
		var window = get_window()
		var is_behind = get_viewport().get_camera_3d().is_position_behind(scan_pos)
		if not is_behind:
			color_rect.position.y = screen_pos.y
			color_rect.position.x = screen_pos.x
			color_rect.position.x = clampf(color_rect.position.x, 0, window.size.x - 40)
			color_rect.position.y = clampf(color_rect.position.y, 0, window.size.y - 40)
			return
		var half:Vector2 = Vector2(window.size.x / 2, window.size.y / 2)
		var dir:Vector2 = screen_pos - Vector2(window.size.x, window.size.y)
		dir = -dir
		if dir.length_squared() < 0.000001:
			dir = Vector2(0, -1)
		
		var abs_dir = Vector2(abs(dir.x), abs(dir.y))
		var max_x = half.x - edge_padding
		var max_y = half.y - edge_padding
		
		var t_x = INF
		var t_y = INF
		if abs_dir.x > 0.0:
			t_x = max_x / abs_dir.x
		if abs_dir.y > 0.0:
			t_y = max_y / abs_dir.y
		
		var t = min(t_x, t_y)
		
		var edge_pos = half + dir * t
		edge_pos.x = clamp(edge_pos.x, edge_padding, window.size.x - edge_padding)
		edge_pos.y = clamp(edge_pos.y, edge_padding, window.size.y - edge_padding)
		
		color_rect.position = edge_pos
