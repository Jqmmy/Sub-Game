class_name Gem
extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"gem interactable".interacted.connect(on_interacted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_interacted():
	freeze = true
