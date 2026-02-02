class_name FishBoid
extends Area3D

var local_boids:Array[FishBoid] = []
var velocity:Vector3
var speed:float  = 0.1
var movv:float = 2.0
var target_influence:float = 1.0
var obstacle:Node3D = null

func _physics_process(delta: float) -> void:
	var target_point:Vector3 = get_parent().global_position
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
		if global_position.distance_to(target_point) > 7:
			speed = move_toward(speed, 50, 1.0 * delta)
		else:
			speed = move_toward(speed, 5, 1.0 * delta)
		
		steerAway /= numOfBoids
		velocity += (steerAway)
		
	if global_position.distance_to(target_point) > 6:
		var point_direction:Vector3
		point_direction = global_position.direction_to(target_point) * target_influence
		velocity += point_direction

	if obstacle:
		velocity += global_position.direction_to(obstacle.global_position) * -target_influence
	
	velocity = velocity.normalized() * speed
	
	global_position += velocity * delta


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("fish"):
		local_boids.append(area)

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("fish"):
		local_boids.erase(area)


func _on_body_entered(body: Node3D) -> void:
	obstacle = body

func _on_body_exited(body: Node3D) -> void:
	obstacle = null
