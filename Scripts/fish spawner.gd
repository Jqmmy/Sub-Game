extends PathFollow3D

const FISH = preload("uid://cagrfw40y8ip7")
var cluster_speed:float = 2.5
@export var center_gem:Gem
@export var fish_amount:int = 650

func _ready() -> void:
	if center_gem:
		center_gem.picked_up.connect(on_center_picked_up)
	
	for fish in fish_amount:
		var boid:FishBoid = FISH.instantiate()
		boid.position =  global_position + Vector3(randf_range(-5, 5,), randf_range(0, 5), randf_range(-5, 5))
		add_child(boid)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode =Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	progress += cluster_speed * delta

func on_center_picked_up() -> void:
	get_tree().call_group("fish", "disperse")
