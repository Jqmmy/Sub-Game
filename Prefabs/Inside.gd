extends Area3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(func(body):
		if body is Player:
			body.motion_mode = CharacterBody3D.MotionMode.MOTION_MODE_GROUNDED
			body.current_speed = body.NORMAL_SPEED)
	body_exited.connect(func(body):
		if body is Player:
			body.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
			body.current_speed = body.WATER_SPEED)
