extends RigidBody3D

@onready var seat_pos: Node3D = $"seat pos"
@onready var control: Control = $Control
@onready var node_3d: Node3D = $Node3D

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
			player.rotate_y(-axis.x * Settings.sens * 4)
		if axis.y > look_margin or axis.y < -look_margin:
			Input.warp_mouse(screen_center + axis * max_dist)
			
			player.camera_3d.rotate_x(-axis.y * Settings.sens * 4)

func _unhandled_input(event: InputEvent) -> void:
	if driving:
		
		if Input.is_action_just_pressed("reset view"):
			var player:Player = get_tree().get_first_node_in_group("player")
			player.camera_3d.rotation = Vector3.ZERO
			player.rotation_degrees = Vector3(0,0,0)
			Input.warp_mouse(control.size / 2)
		
		if Input.is_action_just_pressed("park"):
			parked = !parked
		if Input.is_action_just_pressed("exit cockpit"):
			var player:Player = get_tree().get_first_node_in_group("player")
			driving = false
			player.process_mode = Node.PROCESS_MODE_PAUSABLE
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			player.reparent(get_parent())
			player.global_position = node_3d.global_position

func _physics_process(delta: float) -> void:
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

func _on_interactable_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	driving = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.reparent(self)
	player.global_position = seat_pos.global_position
