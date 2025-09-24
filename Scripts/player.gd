extends CharacterBody3D


var current_speed = 5
var gravity = -9.8
var jump_velocity = 100

var sens:float = 0.05
@export var camera_3d:Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if !get_tree().root.has_focus():
		get_tree().root.grab_focus()
		print(get_tree().root.has_focus())
	var look_vector:Vector2 = Vector2(-Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), -Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))
	var look_margin:float = 0.1
	if look_vector.x > look_margin or look_vector.x < -look_margin:
		rotate_y(look_vector.x * sens)
	if look_vector.y > look_margin or look_vector.y < -look_margin:
		camera_3d.rotate_x(look_vector.y * sens)
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sens)
		camera_3d.rotate_x(-event.relative.y * sens)
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)

func _physics_process(delta: float) -> void:
	
	if !is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_velocity
	
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	if direction:
		velocity = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.y = move_toward(velocity.y, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
