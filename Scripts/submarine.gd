extends RigidBody3D

@export var seat_pos:Node3D
@onready var control: Control = $Control
@onready var node_3d: Node3D = $Node3D
@onready var animationtree: AnimationTree = $"button animationtree"
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var atractor: Area3D = $Atractor
@onready var radar_container: HBoxContainer = $"Control/radar container"
@onready var radar_left: ColorRect = $"Control/radar container/radar left"
@onready var radar_right: ColorRect = $"Control/radar container/radar right"

@onready var radar_fade_timer: Timer = $"radar fade timer"

@onready var ship_depth_ui: Control = $"SubViewport/Ship depth UI"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ship_animation_tree: AnimationTree = $diver/AnimationTree
@onready var map_cam: Camera3D = $"map/map cam"
@onready var sub_viewport: SubViewport = $map/SubViewport

@export_node_path("SubViewport") var viewport:NodePath

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
var using_map:bool = false

var radar_timer:float = 0
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
#var SCAN_LINE:PackedScene = preload("res://Prefabs/submarine fabs/scan_line.tscn")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animationtree.set("parameters/fan blend/blend_position", 0.5)
	if parked:
		gravity_scale = 0
	else:
		gravity_scale = 1
	ship_animation_tree.animation_finished.connect(seat_animation_finished)
	radar_container.modulate = Color(1,1,1,0)


func _input(event: InputEvent) -> void:
	if using_map:
		sub_viewport.push_input(event, true)
	if driving:
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
			radar_container.modulate = Color(1,1,1,1)
			radar_fade_timer.start()
			if radar_timer >= 3.0:
				var scans = get_tree().get_nodes_in_group("scanable")
				var camera_view = get_viewport().get_camera_3d()
				
				#player.head.add_child(SCAN_LINE.instantiate())
				for scan in scans:
					var scan_screen_pos = camera_view.unproject_position(scan.global_position)
					if not camera_view.is_position_in_frustum(scan.global_position):
						continue
					elif scan_screen_pos.x > radar_left.global_position.x and scan_screen_pos.x < radar_right.global_position.x:
						print("scanned")
						if radar_container.custom_minimum_size.x < 50:
							if scan is Waypoint:
								scan.active = true
				radar_timer = 0
			
		if Input.is_action_just_released("radar"):
			radar_timer = 0.0


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
		
		
		radar_timer += delta


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
	ship_depth_ui.radar.arc_position = fposmod(rotation.y, TAU)
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
		
		animationtree.set("parameters/forward backward/blend_position", -input_dir)
		animationtree.set("parameters/left right/blend_position", axis)
		
		if input_dir:
			if input_dir > 0:
				if float_booster == 1.0:
					animationtree["parameters/fan blend/blend_position"] = 0.125
				elif float_booster == -1.0:
					animationtree["parameters/fan blend/blend_position"] = 0.375
				else:
					animationtree["parameters/fan blend/blend_position"] = 0.75
				
			elif input_dir < 0:
				if float_booster == 1.0:
					animationtree["parameters/fan blend/blend_position"] = 0.875
				elif float_booster == -1.0:
					animationtree["parameters/fan blend/blend_position"] = 0.625
				else:
					animationtree["parameters/fan blend/blend_position"] = 0.25
					print(animationtree["parameters/fan blend/blend_position"])
			
			elif float_booster == 1.0:
				animationtree["parameters/fan blend/blend_position"] = 0.0
			elif float_booster == -1.0:
				animationtree["parameters/fan blend/blend_position"] = 0.5
	
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


func _on_map_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	map_cam.make_current()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	using_map = true
	
