extends RigidBody3D

# Bullet properties
var damage_amount = 1.0

func initialize_bullet(velocity, global_transform):
	self.linear_velocity = velocity
	self.global_transform = global_transform

func _on_body_entered(body):
	if body.has_method("apply_damage"):
		body.apply_damage(damage_amount)
	queue_free()
