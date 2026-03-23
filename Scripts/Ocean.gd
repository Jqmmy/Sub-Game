class_name Ocean
extends Area3D

signal player_jumped_in_water
var jumped_in_water:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(func(body): 
		if body is Player:
			if not body.inside_ship:
				print("player in ocean")
				body.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
				body.current_speed = body.WATER_SPEED
			if !jumped_in_water:
				player_jumped_in_water.emit()
			jumped_in_water = true
			
		
		if body.is_in_group("submarine"):
			body.in_water = true
			body.linear_velocity.y = -5
			body.gravity_scale = 0.0)
	body_exited.connect(func(body):
		if body is Player:
			body.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
			body.current_speed = body.NORMAL_SPEED
			if body.is_in_group("submarine"):
				body.in_water = false)
