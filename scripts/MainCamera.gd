extends Camera3D

var target_position: Vector3
var current_position: Vector3

var recoil_speed = 8
var return_speed = 2

func _physics_process(delta):
	target_position = lerp(target_position, Vector3.ZERO, return_speed * delta)
	current_position = lerp(current_position, target_position, recoil_speed * delta)
	rotation_degrees = current_position

func recoil(weapon_recoil):
	target_position.x += weapon_recoil
