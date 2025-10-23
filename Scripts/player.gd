class_name Player
extends CharacterBody3D

var current_speed = NORMAL_SPEED
const WATER_SPEED = 1.25
const NORMAL_SPEED = 4
const WATER_BOOST = 5
const JUMP_VELOCITY = 4.5

var sens:float = 0.05
@export var camera_3d:Camera3D
@export var head:Node3D
@onready var light: SpotLight3D = $head/Camera3D/light
@onready var radar: Radar = $Radar

@onready var skeleton_ik_3d: SkeletonIK3D = $"charecter/Armature/Skeleton3D/left arm IK"
@onready var right_arm_ik: SkeletonIK3D = $"charecter/Armature/Skeleton3D/right arm IK"
@onready var tube_r_ik: SkeletonIK3D = $"charecter/Armature/Skeleton3D/tube r IK"
@onready var tube_l_ik: SkeletonIK3D = $"charecter/Armature/Skeleton3D/tube l IK"


func _ready() -> void:
	tube_l_ik.start()
	tube_r_ik.start()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if !get_tree().root.has_focus():
		get_tree().root.grab_focus()
	var look_vector:Vector2 = Vector2(-Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), -Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))
	var look_margin:float = 0.1
	if look_vector.x > look_margin or look_vector.x < -look_margin:
		head.rotate_y(look_vector.x * sens)
	if look_vector.y > look_margin or look_vector.y < -look_margin:
		camera_3d.rotate_x(look_vector.y * sens)
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * Settings.sens)
		camera_3d.rotate_x(-event.relative.y * Settings.sens)
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)
	
	if Input.is_action_just_pressed("turn off lights"):
		if light.light_energy == 0:
			light.light_energy = 1
		else:
			light.light_energy = 0
	

func _physics_process(delta: float) -> void:

	if motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if radar.scan_closest_object(global_position).distance_squared_to(global_position) > 10:
				print("more than ten", radar.scan_closest_object(global_position).distance_squared_to(global_position), radar.closest_object)
			else:
				print("less than ten")
		
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
	
	else:
		var water_gravity:float = 0.25
		if not is_on_wall():
			water_gravity = -0.25
		else:
			water_gravity = 0
		
		if Input.is_action_just_pressed("sprinting"):
			current_speed = WATER_BOOST
			get_tree().create_timer(1).timeout.connect(func():current_speed = WATER_SPEED)
		
		var float_booster:float
		if Input.is_action_pressed("up"):
			float_booster = 1.0
		if Input.is_action_pressed("down"):
			float_booster = -1.0
		elif !Input.is_action_pressed("up"):
			float_booster = 0
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var camera_direction = (camera_3d.transform.basis * Vector3(input_dir.x, float_booster, input_dir.y)).normalized()
		if direction or camera_direction:
			velocity.x = direction.x * current_speed
			velocity.y = camera_direction.y * current_speed + water_gravity
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.y = move_toward(velocity.y, 0, current_speed) + water_gravity
			velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
