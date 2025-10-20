extends Node3D

@onready var skeleton_ik_3d: SkeletonIK3D = $CharacterBody3D/charecter/Armature/Skeleton3D/SkeletonIK3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skeleton_ik_3d.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
