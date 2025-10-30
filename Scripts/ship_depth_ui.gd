extends Control


@onready var panel_container_2: PanelContainer = $VBoxContainer/PanelContainer/PanelContainer2

func change_depth_sensor(depth:float, range_min:float, range_max:float):
	var depth_normalized = (depth - range_min) / (range_max - range_min)
	
	panel_container_2.custom_minimum_size.y = depth_normalized * 360 + 50
	
