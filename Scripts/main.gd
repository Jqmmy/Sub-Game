extends Node3D

@onready var mesh_instance_3d_9: MeshInstance3D = $MeshInstance3D9


var amplitude := 10   # how far left/right it moves
var speed := 0.5       # how fast the motion is
var base_x := 0.0       # starting X position
var time := 0.0

func _ready():
	base_x = mesh_instance_3d_9.position.x  # store original X

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	time += delta * speed
	mesh_instance_3d_9.position.x = base_x + sin(time) * amplitude
