extends Node3D

@export var submarine_attatchment:MeshInstance3D
@export var deck_door:MeshInstance3D
@export var submarine:RigidBody3D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var back_on_ship_point: Marker3D = $"back on ship point"

var deck_door_open:bool = false

func _ready() -> void:
	var sub = get_node("%Submarine")
	sub.gravity_scale = 0


func _on_use_door_interacted() -> void:
	if not deck_door_open:
		animation_player.play("open close door")
		deck_door_open = true
	else:
		animation_player.play_backwards("open close door")
		deck_door_open = false


func _on_move_forward_interacted() -> void:
	submarine_attatchment.position.z -= 0.05125
	submarine_attatchment.position.z = clampf(submarine_attatchment.position.z, -27.3, -13.559)


func _on_move_backward_interacted() -> void:
	submarine_attatchment.position.z += 0.05125
	submarine_attatchment.position.z = clampf(submarine_attatchment.position.z, -27.3, -13.559)


func _on_lower_sub_interacted() -> void:
	if submarine_attatchment.position.z < -27.0:
		submarine.reparent(get_parent_node_3d())
		submarine.gravity_scale = 1.0
		submarine.open_hatch()
	else:
		pass #add error SFX


func _on_ladder_interact_interacted() -> void:
	var player:Player = get_tree().get_first_node_in_group("player")
	player.global_position = back_on_ship_point.global_position
