extends SubViewportContainer

@export var color_rect:TextureRect
@export var collision_object:CollisionObject3D
@export var cam_look_point:Node3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera_3d: Camera3D = $SubViewport2/Camera3D

var cam_offset:Vector3

func _ready() -> void:
	collision_object.mouse_entered.connect(on_mouse_entered)
	collision_object.mouse_exited.connect(on_mouse_exited)

func _input(event: InputEvent) -> void:
	var mouse_relative:Vector2
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			mouse_relative = event.relative
			if Input.is_action_pressed("pan"):
				cam_offset -= Vector3(mouse_relative.x, 0, mouse_relative.y) * 0.25
		if event.is_action_pressed("zoom in"):
			camera_3d.size -= 1
		if event.is_action_pressed("zoom out"):
			camera_3d.size += 1
	

func _physics_process(delta: float) -> void:
	camera_3d.global_position.x = cam_look_point.global_position.x + cam_offset.x
	camera_3d.global_position.y = cam_look_point.global_position.y + 50
	camera_3d.global_position.z = cam_look_point.global_position.z + cam_offset.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var full_screen_pos:Vector2 = get_viewport().get_mouse_position()
	var screen_pos
	screen_pos = (full_screen_pos - Vector2(0,0))\
	 / Vector2(get_window().size.x, get_window().size.y) - Vector2(0,0)
	print(screen_pos)
	
	color_rect.global_position = screen_pos * get_viewport_rect().size
	
	if Input.is_action_just_pressed("escape"):
		sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	if Input.is_action_just_pressed("fire"):
		color_rect.reparent(get_child(1))
	elif Input.is_action_just_released("fire"):
		color_rect.reparent(self)

func on_mouse_entered():
	pass

func on_mouse_exited():
	pass
