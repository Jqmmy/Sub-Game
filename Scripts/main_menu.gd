extends Node3D

@onready var color_rect: ColorRect = $"Main Menu/ColorRect"
@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var camera_3d: Camera3D = $Path3D/PathFollow3D/Camera3D
@onready var color_rect_2: ColorRect = $"Main Menu/ColorRect2"
@onready var godot_icon: TextureRect = $"Main Menu/ColorRect/godot icon"
@onready var bun_icon: TextureRect = $"Main Menu/ColorRect/bun icon2"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var main_menu: Control = $"Main Menu"
const MAIN_WORLD = preload("uid://d2e2kkuq36jrw")


var ended_path:bool = false
var camera_rot_offset:float = -10

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(color_rect_2, "custom_minimum_size:y", get_window().size.y, 0.5)
	tween.finished.connect(
		func():
			color_rect_2.anchor_bottom = 0.0
			color_rect_2.grow_vertical = Control.GROW_DIRECTION_END
			bun_icon.show()
			godot_icon.hide()
			var rect_tween:Tween = get_tree().create_tween()
			rect_tween.tween_property(color_rect_2, "custom_minimum_size:y", 0.0, 0.5)
			rect_tween.finished.connect(func():
				await get_tree().create_timer(2).timeout
				var modulate_tween:Tween = get_tree().create_tween()
				modulate_tween.tween_property(color_rect, "modulate", Color(0,0,0,0), 1.0)
				modulate_tween.finished.connect(func():
					audio_stream_player.play()
					var path_tween:Tween = get_tree().create_tween()
					path_tween.tween_property(path_follow_3d, "progress_ratio", 1.0, 2.5)
					path_tween.finished.connect(func():
						ended_path = true
						main_menu.hide()
						))))


func _process(delta: float) -> void:
	if ended_path:
		var mouse_uv_pos:Vector2 = \
		get_window().get_mouse_position() / Vector2(get_window().size.x, get_window().size.y) * 2.0 - Vector2(1.0, 1.0)
		mouse_uv_pos = clamp(mouse_uv_pos, Vector2(-1, -1), Vector2(1.0, 1.0))
		camera_3d.rotation_degrees = Vector3(camera_rot_offset * mouse_uv_pos.y, camera_rot_offset * mouse_uv_pos.x, 0.0)

func _on_credits_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("fire"):
		pass

func _on_settings_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("fire"):
		pass

func _on_play_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("fire"):
		get_tree().change_scene_to_packed(MAIN_WORLD)

func _on_quit_area_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("fire"):
		get_tree().quit()
