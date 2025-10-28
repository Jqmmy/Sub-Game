extends RigidBody3D

@onready var seat_pos: Node3D = $"seat pos"
@onready var control: Control = $Control
@onready var node_3d: Node3D = $Node3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

@onready var exit_ik_target: Node3D = $"diver/Cube_017/Exit IK target"
@onready var park_ik_target: Node3D = $"diver/Cube_018/Park IK target"
@onready var map_ik_target: Node3D = $"diver/Cube_001/Map IK target"
@onready var ship_depth_ui: Control = $"SubViewport/Ship depth UI"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@export_node_path("SubViewport") var viewport:NodePath
@export_node_path("Node3D") var IK:NodePath 

var driving:bool = false
var parked:bool = true:
	set(value):
		parked = value
		if parked:
			gravity_scale = 0
		else:
			gravity_scale = 1

var current_speed = 3.0
var rotation_speed = 2.5
var last_rotation_dir:float :
	set(value):
		if value == 0:
			return
		else:
			last_rotation_dir = value
var front_accel = 3.0
var up_accel = 1.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var depth_mesh_material = StandardMaterial3D.new()
	#var depth_viewport_texture = ViewportTexture.new()
	#depth_viewport_texture.viewport_path = viewport
	#depth_mesh_material.albedo_texture = depth_viewport_texture
	#depth_mesh_material.resource_local_to_scene = true
	#mesh_instance_3d.mesh.surface_set_material(0, depth_mesh_material)
	if parked:
		gravity_scale = 0
	else:
		gravity_scale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if driving:
		if !get_tree().root.has_focus():
			get_tree().root.grab_focus()
			
#region mouse & keyboard look controls
		var max_dist = 100
		var screen_center = control.size / 2
		var player:Player = get_tree().get_first_node_in_group("player")
		#if Settings.current_control == Settings.control.KEYBOARD:
			#var mouse_pos = control.get_local_mouse_position()
			#if screen_center.distance_to(mouse_pos) > max_dist:
				#Input.warp_mouse(screen_center + screen_center.direction_to(mouse_pos) * max_dist)
			#var normalized_distance_from_center:float = (screen_center.distance_to(mouse_pos) - 33) / (max_dist - 33)
			#if screen_center.distance_to(mouse_pos) > 33:
				#player.rotate_y(-screen_center.direction_to(mouse_pos).x * normalized_distance_from_center * Settings.sens * 4)
				#player.camera_3d.rotate_x(-screen_center.direction_to(mouse_pos).y * normalized_distance_from_center * Settings.sens * 4)
		#endregion
		#else:
		var axis:Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		var look_margin:float = 0.02
		if axis.x > look_margin or axis.x < -look_margin:
			Input.warp_mouse(screen_center + axis * max_dist)
			player.head.rotate_y(-axis.x * Settings.sens * 4)
		if axis.y > look_margin or axis.y < -look_margin:
			Input.warp_mouse(screen_center + axis * max_dist)
			
			player.camera_3d.rotate_x(-axis.y * Settings.sens * 4)

func _unhandled_input(event: InputEvent) -> void:
	if driving:
		var player:Player = get_tree().get_first_node_in_group("player")
		if Input.is_action_just_pressed("reset view"):
			player.camera_3d.rotation = Vector3.ZERO
			player.rotation_degrees = Vector3(0,0,0)
			Input.warp_mouse(control.size / 2)
		
		if Input.is_action_just_pressed("park"):
			parked = !parked
			player.right_arm_ik.target_node = player.right_arm_ik.get_path_to(park_ik_target)
		if Input.is_action_just_pressed("exit cockpit"):
			player.right_arm_ik.target_node = player.right_arm_ik.get_path_to(exit_ik_target)
			driving = false
			
			player.process_mode = Node.PROCESS_MODE_PAUSABLE
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			player.reparent(get_parent())
			player.global_position = node_3d.global_position
		if Input.is_action_just_pressed("Open map"):
			player.right_arm_ik.target_node = player.right_arm_ik.get_path_to(map_ik_target)
		

func _physics_process(delta: float) -> void:
	
	ship_depth_ui.change_depth_sensor(global_position.y, 0, 500)
	print(global_position.y, " ", ship_depth_ui.panel_container_2.custom_minimum_size.y)
	
	if driving and not parked:
		var float_booster:float
		if Input.is_action_pressed("up"):
			float_booster = 1.0
		if Input.is_action_pressed("down"):
			float_booster = -1.0
		elif !Input.is_action_pressed("up"):
			float_booster = 0
		
		var input_dir = Input.get_axis("forward", "backward")
		var direction = transform.basis * Vector3(0, float_booster, input_dir)
		var axis = Input.get_axis("left", "right")
		apply_torque(Vector3(0, -axis * rotation_speed, 0))
		apply_central_force(direction * current_speed)
		
		var control_stick_normal_dir:float = (input_dir - -1) / (1 - -1)
		var control_look_normal_dir:float = (axis - -1) / (1 - -1)
		animation_tree.set("parameters/blend_amount/blend_amount", control_stick_normal_dir)
		animation_tree.set("parameters/Blend2 2/blend_amount", control_look_normal_dir)
		
		var up_down_fan_direction:float
		if float_booster == 1:
			up_down_fan_direction = -0.5
		elif float_booster == -1:
			up_down_fan_direction = 0.5
		
		if input_dir:
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN)
			if input_dir > 0:
				tween.tween_property(animation_tree, "parameters/fan blend/blend_amount", up_down_fan_direction + 1.5, 0.5)
			elif input_dir < 0:
				tween.tween_property(animation_tree, "parameters/fan blend/blend_amount", -(up_down_fan_direction + 0.5), 0.5)
			print(animation_tree.get("parameters/fan blend/blend_amount"))
		elif float_booster != 0:
			var tween = get_tree().create_tween()
			if float_booster == 1:
				tween.tween_property(animation_tree, "parameters/fan blend/blend_amount", 0.5, 0.5)
			elif float_booster == -1:
				tween.tween_property(animation_tree, "parameters/fan blend/blend_amount", -1.5, 0.5)
	if not driving:
		if shape_cast_3d.is_colliding():
			apply_central_force(Vector3(0,2.5,0))

func _on_interactable_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	driving = true
	player.skeleton_ik_3d.start()
	player.right_arm_ik.start()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.reparent(self)
	player.global_position = seat_pos.global_position
