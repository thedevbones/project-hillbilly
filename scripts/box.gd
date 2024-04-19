extends RigidBody3D


func apply_damage(collision_point, collision_normal, force_magnitude):
	move_box(collision_point, collision_normal, force_magnitude)

func move_box(collision_point, collision_normal, force_magnitude):
	var force_direction = -collision_normal.normalized()
	apply_central_force(force_direction * force_magnitude)

	# Option 2: Set the box's position or translation directly
	# global_position = collision_point + collision_normal * 2 # Move the box 2 units away from the collision point

