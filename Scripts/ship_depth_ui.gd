@tool
extends Control

@onready var radar: Control = $HBoxContainer/VBoxContainer2/radar
@onready var panel_container_2: PanelContainer = $HBoxContainer/VBoxContainer/PanelContainer/PanelContainer2

func change_depth_sensor(depth:float, range_min:float, range_max:float):
	var depth_normalized = (depth - range_min) / (range_max - range_min)
	
	panel_container_2.custom_minimum_size.y = depth_normalized * 360 + 50

func activate_radar(charge_time:float = 2.5) -> void:
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(radar, "radar_charge", 0.0, 0.25)
	
	tween.finished.connect(func():
		var finish_tween:Tween = get_tree().create_tween()
		finish_tween.tween_property(radar, "radar_charge", 100, charge_time))
	
