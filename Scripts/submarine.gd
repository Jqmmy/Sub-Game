extends RigidBody3D

@export var seat_pos:Node3D
@onready var joystick_ik: Marker3D = $"diver/joystick right and left base/Cube_014/control IK"
@onready var buttons_ik: Node3D = $"IK target"
@onready var node_3d: Node3D = $Node3D
@onready var animationtree: AnimationTree = $"button animationtree"
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D
@onready var atractor: Area3D = $Atractor

@onready var ship_depth_ui: Control = $"SubViewport/Ship depth UI"
@onready var ship_animation_tree: AnimationTree = $diver/AnimationTree
@onready var map_cam: Camera3D = $"map/map cam"
@onready var sub_viewport: SubViewport = $map/SubViewport
@onready var map: SubViewportContainer = $map/SubViewport/map
@onready var radar_reference: Marker3D = $"Radar reference"
@onready var radar_rotator_origin: Marker3D = $"radar rotator origin"
@onready var radar_rotator: Marker3D = $"Radar reference/radar rotator"
@onready var joystick_button: MeshInstance3D = $"diver/joystick right and left base/Cube_014/joystick button"

var radar_check_angle:float = 0.0
enum radar_levels {
	level1,
	level2,
	level3,
	level4
}
var current_radar_level:radar_levels = radar_levels.level1:
	set(value):
		match value:
			radar_levels.level1:
				ship_depth_ui.radar.arc_width = 1.571
				radar_check_angle = 0.0
				current_radar_level = value
			radar_levels.level2:
				ship_depth_ui.radar.arc_width = 1.17825
				radar_check_angle = 0.25
				current_radar_level = value
			radar_levels.level3:
				ship_depth_ui.radar.arc_width = 0.7855
				radar_check_angle = 0.5
				current_radar_level = value
			radar_levels.level4:
				ship_depth_ui.radar.arc_width = 0.39275
				radar_check_angle = 0.75
				current_radar_level = value
			_:
				push_error("wrong number for radar level")


var is_radar_charged:bool = true
var driving:bool = false
var exiting:bool = true
var times_in_seat:int = -1
var hatch_open:bool = false
var using_map:bool = false
var in_water:bool = false

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

@onready var player:Player = get_tree().get_first_node_in_group("player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animationtree.set("parameters/fan blend/blend_position", 0.5)
	ship_animation_tree.animation_finished.connect(seat_animation_finished)
	var ui_viewport:Texture2D = $SubViewport.get_texture()
	var ui_material:StandardMaterial3D = StandardMaterial3D.new()
	ui_material.albedo_texture = ui_viewport
	ui_material.uv1_offset = Vector3(-0.015,-0.64,0.0)
	ui_material.uv1_scale = Vector3(1.01,1.635, 1.0)
	$"diver/map button_001".set_surface_override_material(0, ui_material)
	var map_viewport:Texture2D = $map/SubViewport.get_texture()
	var map_material:StandardMaterial3D = StandardMaterial3D.new()
	map_material.albedo_texture = map_viewport
	
	$diver/sub.set_surface_override_material(1, map_material)


func _input(event: InputEvent) -> void:
	if using_map:
		sub_viewport.push_input(event, true)
		if Input.is_action_just_pressed("exit cockpit"):
			var player = get_tree().get_first_node_in_group("player") as Player
			var unpause_timer:SceneTreeTimer = get_tree().create_timer(0.1)
			player.camera_3d.make_current()
			unpause_timer.timeout.connect(func(): player.pause(false))
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			using_map = false
	if driving:
		if Input.is_action_just_pressed("radar") and is_radar_charged:
			is_radar_charged = false
			get_tree().create_timer(2.5).timeout.connect(func():
				is_radar_charged = true)
			ship_depth_ui.activate_radar(2.5)
			var radar_direction:Vector3 = radar_rotator_origin.global_position.direction_to(radar_rotator.global_position)
			var objectives:Array[Node] = get_tree().get_nodes_in_group("scanable")
			for objective in objectives:
				if objective is Node3D:
					var object_direction:Vector3 = Vector3(radar_reference.global_position.x, 0 , radar_reference.global_position.z).\
					direction_to(Vector3(objective.global_position.x,0,objective.global_position.z))
					if object_direction.dot(radar_direction) > radar_check_angle:
						if objective is Waypoint:
							objective.active = true
					
		if Input.is_action_just_pressed("short radar"):
			current_radar_level += 1
			joystick_button.rotation_degrees.x = -33
		if Input.is_action_just_pressed("long radar"):
			joystick_button.rotation_degrees.x = -13
			current_radar_level -= 1
	
		if Input.is_action_just_pressed("fire"):
			var tween = get_tree().create_tween()
			tween.tween_property(player.camera_3d,"fov" , 60, 0.2)
		if Input.is_action_just_released("fire"):
			var tween = get_tree().create_tween()
			tween.tween_property(player.camera_3d,"fov" , 80, 0.2)

func _process(delta: float) -> void:
	if driving:
		if !get_tree().root.has_focus():
			get_tree().root.grab_focus()
			
		var axis:Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		var look_margin:float = 0.02
		if axis.x > look_margin or axis.x < -look_margin:
			player.head.rotate_y(-axis.x * Settings.controller_sens)
		if axis.y > look_margin or axis.y < -look_margin:
			player.camera_3d.rotate_x(-axis.y * Settings.controller_sens)
		
		player.camera_3d.rotation_degrees.x = clampf(player.camera_3d.rotation_degrees.x, -45, 45)
		player.head.rotation_degrees.y = clampf(player.head.rotation_degrees.y, -90, 90)
		
		radar_timer += delta


func _unhandled_input(event: InputEvent) -> void:
	if driving:
		var player:Player = get_tree().get_first_node_in_group("player")
		if event is InputEventMouseMotion:
			player.head.rotate_y(-event.relative.x * Settings.sens)
			player.head.rotation_degrees.y = clamp(player.head.rotation_degrees.y, -90, 90)
			player.camera_3d.rotate_x(-event.relative.y * Settings.sens)
			player.camera_3d.rotation_degrees.x = clamp(player.camera_3d.rotation_degrees.x, -45, 45)
			
		if Input.is_action_just_pressed("reset view"):
			player.camera_3d.rotation = Vector3.ZERO
			player.head.rotation = Vector3.ZERO
	
		if Input.is_action_just_pressed("exit cockpit"):
			ship_animation_tree["parameters/Transition 2/transition_request"] = "b"
			player.animation_tree.set("parameters/sitting/add_amount", 0.0)
			player.arms_ik.active = false
			player.hand_transforms.active = false
			driving = false
			exiting = true
	
		if Input.is_action_just_pressed("Open map"):
			pass
			


func _physics_process(delta: float) -> void:
	var radar_axis:float = Input.get_axis("radar left", "radar right")
	if radar_axis:
		radar_reference.rotation_degrees.y -= radar_axis
	ship_depth_ui.radar.arc_position = deg_to_rad(radar_reference.rotation_degrees.y) * -1
	ship_depth_ui.change_depth_sensor(global_position.y, 0, -150)
	if driving:
		
		var float_booster:float
		var player:Player = get_tree().get_first_node_in_group("player")
		if Input.is_action_pressed("up"):
			player.animation_tree.set("parameters/pedal add/add_amount", 1)
			float_booster = 1.0
		if Input.is_action_pressed("down"):
			player.animation_tree.set("parameters/pedal add/add_amount", -1)
			float_booster = -1.0
		elif !Input.is_action_pressed("up"):
			player.animation_tree.set("parameters/pedal add/add_amount", 0)
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
			
			elif float_booster == 1.0:
				animationtree["parameters/fan blend/blend_position"] = 0.0
			elif float_booster == -1.0:
				animationtree["parameters/fan blend/blend_position"] = 0.5
	
	if not driving and in_water:
		if shape_cast_3d.is_colliding():
			apply_central_force(Vector3(0,2.0,0))
			


func _on_interactable_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	var tween = get_tree().create_tween()
	player.pause(true)
	player.reparent(seat_pos)
	player.light.light_energy = 0
	player.animation_tree.set("parameters/add walking/add_amount", 0.0)
	player.animation_tree.set("parameters/sitting/add_amount", 1.0)
	
	tween.tween_property(player, "global_transform", seat_pos.global_transform, 0.75)
	tween.finished.connect(func(): 
		ship_animation_tree["parameters/Transition 2/transition_request"] = "f"
		player.global_transform = seat_pos.global_transform)
	exiting = false


func seat_animation_finished(anim_name:String):
	var player = get_tree().get_first_node_in_group("player") as Player
	if anim_name == "get in seat":
		times_in_seat += 1
		if exiting and times_in_seat > 0:
			player.pause(false)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			player.reparent(get_parent())
			player.global_position = node_3d.global_position
		elif times_in_seat > 0:
			driving = true
			player.set_ik_targets(joystick_ik, buttons_ik, true, 1.0)
			player.arms_ik.active = true
			player.hand_transforms.active = true
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

func _on_map_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	map_cam.make_current()
	player.pause(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	using_map = true
	


func _on_update_map_timer_timeout() -> void:
	if Vector2(linear_velocity.x, linear_velocity.z) > Vector2.ZERO:
		map.update_fog(Vector2(global_position.x, global_position.z), 30)


func _on_net_interactable_interacted() -> void:
	var player:Player = get_tree().get_first_node_in_group("player")
	if player.is_holding_gem:
		var gem = player.gem_hold_spot.get_child(0)
		if gem is Gem:
			gem.reparent(self)
			gem.global_position = $"net Interactable".global_position 
			player.is_holding_gem = false
	else:
		pass

func open_hatch() -> void:
	atractor.active = true
	ship_animation_tree["parameters/hatch/transition_request"] = "open"
