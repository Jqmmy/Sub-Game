class_name Player
extends CharacterBody3D

var current_speed = NORMAL_SPEED
const WATER_SPEED = 1.25
const NORMAL_SPEED = 4
const WATER_BOOST = 3
const JUMP_VELOCITY = 4.5
var radar_is_up:bool = false
var is_holding_gem:bool = false

var ray_cast_is_hovering:bool = false
var last_raycast_hover_target:Interactable

@export var camera_3d:Camera3D
@export var head:Node3D
@export var skeleton:Skeleton3D
@export var gem_hold_spot:Marker3D
@onready var light: SpotLight3D = $head/Camera3D/light
@onready var radar:WristRadar = $Radar
@onready var looking_direction: Marker3D = $"head/looking direction"

@export var skeleton_ik_3d: SkeletonIK3D
@export var right_arm_ik: SkeletonIK3D 
@onready var charecter: Node3D = $charecter
@onready var animation_tree: AnimationTree = $charecter/AnimationTree
@onready var radar_target_dist_label: Label = $"Radar/wrist UI/VBoxContainer/HBoxContainer/radar target dist"
@onready var ray_cast_3d: RayCast3D = $head/Camera3D/RayCast3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if radar_is_up:
		var distance_to_gem = global_position.distance_squared_to(radar.scan_closest_object(global_position))
		if distance_to_gem > 1000:
			radar_target_dist_label.text = "ERROR"
		else:
			radar_target_dist_label.text = str(int(distance_to_gem)) + "M"
	
	#hovering logic
	if ray_cast_3d.is_colliding():
		var collider:CollisionObject3D = ray_cast_3d.get_collider()
		match collider:
			_ when collider is Interactable:
				if collider != last_raycast_hover_target and last_raycast_hover_target:
					last_raycast_hover_target.hovering = false
				ray_cast_is_hovering = true
				collider.hovering = true
				last_raycast_hover_target = collider
				if collider.is_in_group("gem"):
					collider.interacted.connect(
					func():
						if collider.get_parent() is Gem:
							if not is_holding_gem:
								var gem = collider.get_parent()
								gem.reparent(gem_hold_spot)
								gem.global_transform = gem_hold_spot.global_transform
								is_holding_gem = true)
			_ when collider != Interactable and last_raycast_hover_target:
				ray_cast_is_hovering = false
				last_raycast_hover_target.hovering = false
			
	elif ray_cast_is_hovering:
		ray_cast_is_hovering = false
		last_raycast_hover_target.hovering = false


func _unhandled_input(event: InputEvent) -> void:
	#var look_vector:Vector2 = Vector2(-Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), -Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))
	#var look_margin:float = 0.1
	#if look_vector.x > look_margin or look_vector.x < -look_margin:
		#if head.rotation.y < 0.5 and head.rotation.y > -0.5:
			#head.rotate_y(look_vector.x * sens)
		#else:
			#rotate_y(look_vector.x * sens)
			#head.rotation.y = clamp(head.rotation.y, -0.5, 0.5)
	#else:
		#if head.rotation.y >= 0.5:
			#head.rotation.y = 0.49
		#elif head.rotation.y <= -0.5:
			#head.rotation.y = -0.49
		#
	#if look_vector.y > look_margin or look_vector.y < -look_margin:
		#camera_3d.rotate_x(look_vector.y * sens)
		#camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * Settings.sens)
		head.rotation.y = clamp(head.rotation.y, -0.5, 0.5)
		
		camera_3d.rotate_x(-event.relative.y * Settings.sens)
		camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)
		#if head.rotation.y < 0.5 or head.rotation.y > -0.5:
			#head.rotate_y(-event.relative.x * Settings.sens)
			#print(head.rotation.y)
		#else:
			#rotate_y(-event.relative.x * sens)
			#head.rotation.y = clamp(head.rotation.y, -0.5, 0.5)
		#
		#camera_3d.rotate_x(-event.relative.y * Settings.sens)
		#camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -45, 45)
	#else:
		#if head.rotation.y >= 0.5:
			#head.rotation.y = 0.49
		#elif head.rotation.y <= -0.5:
			#head.rotation.y = -0.49
	
	if Input.is_action_just_pressed("turn off lights"):
		if light.light_energy == 0:
			light.light_energy = 1
		else:
			light.light_energy = 0
	if Input.is_action_just_pressed("radar"):
		if animation_tree.get("parameters/Transition/current_state") == "state_1":
			animation_tree.set("parameters/Transition/transition_request", "state_2")
		else:
			animation_tree.set("parameters/Transition/transition_request", "state_1")
	

func _physics_process(delta: float) -> void:

	if motion_mode == MotionMode.MOTION_MODE_GROUNDED:
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
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
		var direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
