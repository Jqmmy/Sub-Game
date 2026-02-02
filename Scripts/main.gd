extends Node3D
@onready var node_3d: Node3D = $Node3D

const FISH = preload("uid://cagrfw40y8ip7")


func _ready() -> void:
	var fish_amount:int = 650
	
	for fish in fish_amount:
		var boid:FishBoid = FISH.instantiate()
		boid.position =  node_3d.position + Vector3(randf_range(-5, 5,), randf_range(0, 5), randf_range(-5, 5))
		node_3d.add_child(boid)
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode =Input.MOUSE_MODE_VISIBLE
