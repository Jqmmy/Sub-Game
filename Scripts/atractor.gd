extends Area3D

@export var active:bool = false
@export var atractor_speed:float = 10

func _process(_delta: float) -> void:
	if !active:
		return
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			body.velocity = body.global_position.direction_to(global_position) * atractor_speed
