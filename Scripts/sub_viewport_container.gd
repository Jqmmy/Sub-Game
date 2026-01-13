extends SubViewportContainer

@export var collision_object:CollisionObject3D
@export var cam_look_point:Node3D
@export var zoom_speed:float = 10
@export var pan_speed:float = 0.25

@onready var camera_3d: Camera3D = $SubViewport2/Camera3D

var cam_offset:Vector3

var fog_image:Image
var fog_texture:ImageTexture
var map_size:Vector2i = Vector2i(512, 512)
var world_size:Vector2 = Vector2(200, 200)

func _ready() -> void:
	collision_object.mouse_entered.connect(on_mouse_entered)
	collision_object.mouse_exited.connect(on_mouse_exited)
	
	fog_image = Image.create_empty(map_size.x, map_size.y, false, Image.FORMAT_L8)
	fog_image.fill(Color.BLACK)
	
	fog_texture = ImageTexture.create_from_image(fog_image)
	

func _input(event: InputEvent) -> void:
	var mouse_relative:Vector2
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			mouse_relative = event.relative
			if Input.is_action_pressed("pan"):
				cam_offset -= Vector3(mouse_relative.x, 0, mouse_relative.y) * pan_speed
		if event.is_action_pressed("zoom in"):
			camera_3d.size -= zoom_speed
		if event.is_action_pressed("zoom out"):
			camera_3d.size += zoom_speed
	

func _physics_process(delta: float) -> void:
	camera_3d.global_position.x = cam_look_point.global_position.x + cam_offset.x
	camera_3d.global_position.y = cam_look_point.global_position.y + 50
	camera_3d.global_position.z = cam_look_point.global_position.z + cam_offset.z

func on_mouse_entered():
	pass

func on_mouse_exited():
	pass


func world_to_fog(world_pos:Vector2) -> Vector2i:
	var uv = world_pos / world_size
	return Vector2i(
		int(uv.x * map_size.x), 
		int(uv.y * map_size.y)
		)

func update_fog(world_pos:Vector2, radius:float):
	var fog_pos = world_to_fog(world_pos)
	
	
