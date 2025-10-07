class_name Radar
extends Node

func _ready() -> void:
	scan_closest_object(Vector3(0,0,0))

func scan_closest_object(scan_position:Vector3) -> Vector3:
	var scanable_objects = get_tree().get_nodes_in_group("scanable")
	var closest_object:Vector3
	for object in scanable_objects:
		if object is Node3D:
			var object_distance = object.global_position.distance_squared_to(scan_position)
			var close_object_distance = closest_object.distance_squared_to(scan_position)
			if scanable_objects.find(object) == 0:
				closest_object = object.global_position
			elif object_distance < close_object_distance:
				closest_object = object.global_position
	
	return closest_object

func get_scannable_objects() -> Array[Vector3]:
	var scanable_objects = get_tree().get_nodes_in_group("scanable")
	var object_positions:Array[Vector3]
	for object in scanable_objects:
		if object is Node3D:
			object_positions.append(object.global_position)
			
	return object_positions
