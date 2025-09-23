extends CharacterBody3D


var current_speed = NORMAL_SPEED
const NORMAL_SPEED = 5
const BOOST_SPEED = 20.0

var sens:float = 0.05
var boosting:bool = false
var boosts:int = 3
@export var camera_3d:Camera3D
@onready var label: Label = $Label 
@onready var timer: Timer = $Timer


func _ready() -> void:
	print(get_tree().root.has_focus())
	timer.timeout.connect(timeout)

func _process(delta: float) -> void:
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
	if Input.is_action_just_pressed("sprinting") and boosts > 0:
		boosting = true
		boosts -= 1
		current_speed = BOOST_SPEED
		timer.start()
	if boosting:
		current_speed = lerpf(current_speed, NORMAL_SPEED, 1.0 - exp(-1.0 * delta))
		if current_speed < 5.5:
			current_speed = 5
			boosting = false
	label.text = str(boosts)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var float_booster:float
	if Input.is_action_pressed("up"):
		float_booster = 1.0
	if Input.is_action_pressed("down"):
		float_booster = -1.0
	
	var camera_direction := camera_3d.transform.basis * Vector3(input_dir.x, float_booster, input_dir.y)
	var direction = (transform.basis * camera_direction).normalized()
	var direction_up = (transform.basis * camera_3d.transform.basis) * Vector3(0,1.0,0)
	
	if direction:
		velocity = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.y = move_toward(velocity.y, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()

func timeout():
	if boosts > 3:
		boosts = 3
		print("wot")
		return
	
	get_tree().create_timer(2).timeout.connect(
		func():
			boosts += 1
			if boosts != 3:
				timeout())
