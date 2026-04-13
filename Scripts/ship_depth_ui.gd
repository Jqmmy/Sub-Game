@tool
extends Control

@export var radar: Control
@onready var panel_container_2: PanelContainer = $HBoxContainer/VBoxContainer/PanelContainer/PanelContainer2
@onready var fade_timer: Timer = $"fade timer"

func change_depth_sensor(depth:float, range_min:float, range_max:float):
	var depth_normalized = (depth - range_min) / (range_max - range_min)
	
	panel_container_2.custom_minimum_size.y = depth_normalized * 360 + 50

func activate_radar(charge_time:float = 2.5) -> void:
	fade_timer.wait_time = charge_time + 1
	radar.self_modulate = Color(1.0,1.0,1.0,1.0)
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(radar, "radar_charge", 0.0, 0.25)
	
	tween.finished.connect(func():
		var finish_tween:Tween = get_tree().create_tween()
		finish_tween.tween_property(radar, "radar_charge", 100, charge_time))
	
	fade_timer.start()


func _on_fade_timer_timeout() -> void:
	var fade_tween:Tween = get_tree().create_tween()
	fade_tween.tween_property(radar, "self_modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
