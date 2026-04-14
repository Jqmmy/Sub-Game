extends SubViewportContainer

@export var pan_speed:float = 0.25
@export var fog_reveal_radius:float

@onready var camera_3d: Camera3D = $SubViewport2/Camera3D
@onready var map_mesh: MeshInstance3D = $"map mesh"

var cam_offset:Vector3

var fog_image:Image
var fog_texture:ImageTexture
var map_size:Vector2i = Vector2i(512, 512)
var world_size:Vector2 = Vector2(200, 200)
var submarine:RigidBody3D 

func _ready() -> void:
	submarine = get_tree().get_first_node_in_group("submarine")
	fog_image = Image.create_empty(map_size.x, map_size.y, true, Image.FORMAT_LA8)
	fog_image.fill(Color.WHITE)
	
	fog_texture = ImageTexture.create_from_image(fog_image)
	
	map_mesh.mesh.surface_get_material(0).albedo_texture = fog_texture

func _input(event: InputEvent) -> void:
	var mouse_relative:Vector2
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			mouse_relative = event.relative
			if Input.is_action_pressed("pan"):
				cam_offset -= Vector3(mouse_relative.x, 0, mouse_relative.y) * pan_speed
	

func _physics_process(delta: float) -> void:
	if submarine:
		camera_3d.global_position.x = submarine.global_position.x + cam_offset.x
		camera_3d.global_position.z = submarine.global_position.z + cam_offset.z
		camera_3d.rotation.y = submarine.rotation.y

func world_to_fog(world_pos:Vector2) -> Vector2i:
	var uv = world_pos / world_size
	return Vector2i(
		int(uv.x * map_size.x) + map_size.x/2, 
		int(uv.y * map_size.y) + map_size.y/2
		)

func update_fog(world_pos:Vector2, radius:float):
	var fog_pos = world_to_fog(world_pos)
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			if x * x + y * y <= radius * radius:
				var px = fog_pos.x + x
				var py = fog_pos.y + y
				if px < 0 or py < 0 or px >= map_size.x or py >= map_size.y:
					continue
				
				fog_image.set_pixel(px, py, Color(0.0, 0.0, 0.0, 0.0))
	
	fog_texture.update(fog_image)
	

func _on_fog_update_timer_timeout() -> void:
	if submarine:
		var sub_vel = Vector3(submarine.linear_velocity.x,0,submarine.linear_velocity.z)
		if !sub_vel.is_zero_approx():
			update_fog(Vector2(submarine.global_position.x, submarine.global_position.z), fog_reveal_radius)
