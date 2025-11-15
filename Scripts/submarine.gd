extends RigidBody3D

@export var seat_pos:Node3D
@onready var control: Control = $Control
@onready var node_3d: Node3D = $Node3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var atractor: Area3D = $Atractor
@onready var radar_container: HBoxContainer = $"Control/radar container"
@onready var radar_fade_timer: Timer = $"radar fade timer"

@onready var ship_depth_ui: Control = $"SubViewport/Ship depth UI"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ship_animation_tree: AnimationTree = $diver/AnimationTree
@export_node_path("SubViewport") var viewport:NodePath
@export_node_path("Node3D") var IK:NodePath 

var driving:bool = false
var exiting:bool = true
var hatch_open:bool = false
var parked:bool = true:
	
	set(value):
		parked = value
		if parked:
			gravity_scale = 0
		else:
			gravity_scale = 1

var radar_timer:float
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
	if parked:
		gravity_scale = 0
	else:
		gravity_scale = 1
	ship_animation_tree.animation_finished.connect(seat_animation_finished)
	radar_container.modulate = Color(1,1,1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if driving:
		if !get_tree().root.has_focus():
			get_tree().root.grab_focus()
			
		var player:Player = get_tree().get_first_node_in_group("player")
	
		var axis:Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		var look_margin:float = 0.02
		if axis.x > look_margin or axis.x < -look_margin:
			player.head.rotate_y(-axis.x * Settings.sens * 4)
		if axis.y > look_margin or axis.y < -look_margin:
			player.camera_3d.rotate_x(-axis.y * Settings.sens * 4)
		
		#set up rotation clamps here at some point
		
		var radar_change_speed:float = 50.0
		
		
		if Input.is_action_pressed("long radar"):
			radar_container.custom_minimum_size.x += radar_change_speed * get_process_delta_time()
			radar_container.modulate = Color(1,1,1,1)
			radar_fade_timer.start()
			
		if Input.is_action_pressed("short radar"):
			radar_container.custom_minimum_size.x -= radar_change_speed * get_process_delta_time()
			radar_container.modulate = Color(1,1,1,1)
			radar_fade_timer.start()
			
		radar_container.custom_minimum_size.x = clamp(radar_container.custom_minimum_size.x, 40, 750)
		
		if Input.is_action_pressed("radar"):
			var radar_ui_to_angle:float = -0.000391549 * radar_container.custom_minimum_size.x + 1.01366196
			radar_container.modulate = Color(1,1,1,1)
			radar_fade_timer.start()
			radar_timer += delta
			if radar_timer >= 3.0:
				var scans = get_tree().get_nodes_in_group("scanable")
				for scan in scans:
					var direction_to_scan = Vector3(player.head.global_position.x, 0, player.head.global_position.z).direction_to(Vector3(scan.global_position.x, 0,scan.global_positionn.z))
					var player_facing_direction = Vector3(player.head.global_position.x, 0, player.head.global_position.z).direction_to(Vector3(player.looking_direction.global_position.x, 0, player.looking_direction.global_position.z))
					
					print(direction_to_scan.dot(player_facing_direction))
					if direction_to_scan.dot(player_facing_direction) > radar_ui_to_angle:
						print(scan)
				radar_timer = 0
		if Input.is_action_just_released("radar"):
			radar_timer = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if driving:
		var player:Player = get_tree().get_first_node_in_group("player")
		if Input.is_action_just_pressed("reset view"):
			player.camera_3d.rotation = Vector3.ZERO
			player.head.rotation = Vector3.ZERO
			Input.warp_mouse(control.size / 2)
	
		if Input.is_action_just_pressed("park"):
			parked = !parked
	
		if Input.is_action_just_pressed("exit cockpit"):
			ship_animation_tree["parameters/Transition 2/transition_request"] = "b"
			radar_container.hide()
			driving = false
			exiting = true
	
		if Input.is_action_just_pressed("Open map"):
			pass
			
		
		
		


func _physics_process(delta: float) -> void:
	ship_depth_ui.change_depth_sensor(global_position.y, 0, 500)
	
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
	var tween = get_tree().create_tween()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.reparent(seat_pos)
	player.light.light_energy = 0
	
	
	tween.tween_property(player, "global_transform", seat_pos.global_transform, 1.25)
	tween.finished.connect(func(): ship_animation_tree["parameters/Transition 2/transition_request"] = "f")
	exiting = false


func seat_animation_finished(anim_name:String):
	var player = get_tree().get_first_node_in_group("player") as Player
	if anim_name == "get in seat":
		if exiting:
			player.process_mode = Node.PROCESS_MODE_PAUSABLE
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			player.reparent(get_parent())
			player.global_position = node_3d.global_position
		else:
			driving = true
			player.skeleton_ik_3d.start()
			player.right_arm_ik.start()
			player.animation_tree.set("parameters/Transition/transition_request", "state_0")


func _on_button_interacted() -> void:
	ship_animation_tree["parameters/OneShot/request"] = 1
	ship_animation_tree.animation_finished.connect(func(anim_name):
		if anim_name == "push door button":
			if ship_animation_tree["parameters/Transition/current_state"] == "open":
				ship_animation_tree["parameters/Transition/transition_request"] = "close"
			else:
				ship_animation_tree["parameters/Transition/transition_request"] = "open")
				


func _on_entrance_area_body_entered(body: Node3D) -> void:
	if not atractor.active:
		get_tree().create_timer(2.0).timeout.connect(func():
			if not atractor.active:
				body.velocity.y -= 50
				atractor.active = true)
		ship_animation_tree["parameters/hatch/transition_request"] = "open"
		ship_animation_tree["parameters/Transition/transition_request"] = "close"


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if atractor.active:
		get_tree().create_timer(3.0).timeout.connect(func():
			atractor.active = false)
		ship_animation_tree["parameters/hatch/transition_request"] = "close"
		ship_animation_tree["parameters/Transition/transition_request"] = "open"
		


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if ship_animation_tree["parameters/Transition/current_state"] == "open":
		ship_animation_tree["parameters/Transition/transition_request"] = "close"


func _on_radar_fade_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(radar_container, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
