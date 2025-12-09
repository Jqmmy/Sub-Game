extends MeshInstance3D

@export var speed:float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spawned")
	get_tree().create_timer(5).timeout.connect(func():
		queue_free())

func _physics_process(delta: float) -> void:
	print(global_position)
	global_position.z -= speed * delta
