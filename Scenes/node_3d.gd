#ship movement code base is there but not configured to be apart of the ship
extends CharacterBody3D


var current_speed = 6.0
var rotation_speed = 3.5
var front_accel = 3.0
var up_accel = 2.0
var driving:bool = false

@onready var seat_pos: Node3D = $"seat pos"


func _ready() -> void:
	print(get_tree().root.has_focus())

func _process(delta: float) -> void:
	if driving:
		if !get_tree().root.has_focus():
			get_tree().root.grab_focus()
			print(get_tree().root.has_focus())
		var look_vector:Vector2 = Vector2(-Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), -Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))
		var look_margin:float = 0.1
		if look_vector.x > look_margin or look_vector.x < -look_margin:
			rotate_y(look_vector.x * Settings.sens)
		if look_vector.y > look_margin or look_vector.y < -look_margin:
			pass
		var screen_center = get_tree().get_root().size / 2
		var mouse_pos = DisplayServer.mouse_get_position()
		var max_dist = 30
		if mouse_pos.distance_squared_to(screen_center) > max_dist:
			

func _unhandled_input(event: InputEvent) -> void:
	if driving:
		pass
		#if event is InputEventMouseMotion:
			#rotate_y(-event.relative.x * Settings.sens)
		

func _physics_process(delta: float) -> void:
	pass
	if driving:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var float_booster:float
		if Input.is_action_pressed("up"):
			float_booster = 1.0
		if Input.is_action_pressed("down"):
			float_booster = -1.0
		elif !Input.is_action_pressed("up"):
			float_booster = 0
		
		var camera_direction := transform.basis * Vector3(-input_dir.x, float_booster, -input_dir.y)
		var direction = (transform.basis * camera_direction).normalized()
		#var direction_up = (transform.basis * camera_3d.transform.basis) * Vector3(0,1.0,0)
		
		if direction:
			#velocity = camera_direction * current_speed
			velocity.x = move_toward(velocity.x, camera_direction.x * current_speed, front_accel * delta)
			velocity.y = move_toward(velocity.y, camera_direction.y * current_speed, up_accel * delta)
			velocity.z = move_toward(velocity.z, camera_direction.z * current_speed, front_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed * delta)
			velocity.y = move_toward(velocity.y, 0, current_speed * delta)
			velocity.z = move_toward(velocity.z, 0, current_speed * delta)
		
		move_and_slide()


func _on_interactable_interacted() -> void:
	var player = get_tree().get_first_node_in_group("player") as Player
	driving = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.reparent(self)
	player.position = seat_pos.position
