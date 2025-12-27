class_name FishBoid
extends Area3D

var local_boids:Array[FishBoid] = []
var velocity:Vector3
var speed:float  = 0.1
var movv:float = 1.1
var target_influence:float = 0.1

func _physics_process(delta: float) -> void:
	
#region boid algo
	if local_boids:
		var numOfBoids := local_boids.size()
		var avgVel := Vector3.ZERO
		var avgPos := Vector3.ZERO
		var steerAway := Vector3.ZERO
		for boid in local_boids:
			avgVel += boid.velocity
			avgPos += boid.position
			steerAway -= (boid.global_position - global_position) * (movv/( global_position - boid.global_position).length())

		avgVel /= numOfBoids
		velocity += (avgVel - velocity)/2

		avgPos /= numOfBoids
		velocity += (avgPos - position)

		steerAway /= numOfBoids
		velocity += (steerAway)
#endregion
	var target_point:Vector3 = get_parent().global_position
	if global_position.distance_to(target_point) > 12:
		var point_direction:Vector3
		point_direction = global_position.direction_to(target_point) * target_influence
		velocity += point_direction
	elif global_position.distance_to(target_point) < 6.0:
		var point_direction:Vector3
		point_direction = target_point.direction_to(global_position) * target_influence
		velocity += point_direction
	
	velocity = velocity.normalized() * speed
	
	global_position += velocity




func _on_area_entered(area: Area3D) -> void:
	local_boids.append(area)


func _on_area_exited(area: Area3D) -> void:
	local_boids.erase(area)
