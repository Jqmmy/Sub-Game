extends Node3D

@export var submarine_attatchment:MeshInstance3D
@export var deck_door:MeshInstance3D
@export var submarine:RigidBody3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var deck_door_open:bool = false

func _on_use_door_interacted() -> void:
	if not deck_door_open:
		animation_player.play("open close door")
		deck_door_open = true
	else:
		animation_player.play_backwards("open close door")
		deck_door_open = false


func _on_move_forward_interacted() -> void:
	submarine_attatchment.position.z += -0.05125
	submarine.position.z += 0.05125
	submarine_attatchment.position.z = clampf(submarine_attatchment.position.z, -13.559, -27.3)
	submarine.position.z = clampf(submarine.position.z, 12, 25.75)


func _on_move_backward_interacted() -> void:
	submarine_attatchment.position.z += 0.05125
	submarine.position.z += -0.05125
	submarine_attatchment.position.z = clampf(submarine_attatchment.position.z, -13.559, -27.3)
	submarine.position.z = clampf(submarine.position.z, 12, 25.75)


func _on_lower_sub_interacted() -> void:
	pass
