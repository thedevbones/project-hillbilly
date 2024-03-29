extends "res://scripts/Weapon.gd"

const ADS_POS = Vector3(0, -0.4, -1.058)
const ADS_ROT = Vector3(0, 0, 0)
const BOB_SPEED = 0.05

func _ready():
	damage = 1
	max_ammo = 8
	ammo = max_ammo
	reload_time = 1.5
	range = Vector3(1.0, 1.0, 100)
	ranged = true
	original_pos = position
	original_rot = rotation
	target_pos = original_pos
	target_rot = original_rot
	ads_pos = ADS_POS
	ads_rot = ADS_ROT
	fire_sound = $PistolFire
	reload_sound = $PistolReload

func _process(delta):
	if not visible: pass
	
	if position.z > original_pos.z: 
		position.z = lerp(position.z, original_pos.z, 10.0 * delta)
	
	position.x = lerp(position.x, target_pos.x, 10.0 * delta)
	rotation = rotation.slerp(target_rot, 10.0 * delta)
	
	if is_aiming:
		position.y = lerp(position.y, -0.2, 10.0 * delta)
	elif is_reloading: 
		position.y = lerp(position.y, -0.6, 10.0 * delta)
	elif position.y > -0.38: 
		position.y = lerp(position.y, -0.38, 10.0 * delta)
		bob_up = false
	elif position.y < -0.42: 
		position.y = lerp(position.y, -0.42, 10.0 * delta)
		bob_up = true
	
	var bob_speed
	if not $"../..".is_moving or $"../..".is_crouching:
		bob_speed = BOB_SPEED * 0.25
	elif $"../..".is_sprinting:
		bob_speed = BOB_SPEED * 2
	else:
		bob_speed = BOB_SPEED 
	
	if bob_up:
		if position.y >= bob_max: bob_up = false
		position.y += bob_speed * delta
	else:
		if position.y <= bob_min: bob_up = true
		position.y -= bob_speed * delta

func _on_visibility_changed():
	if is_aiming and not visible: aim()
