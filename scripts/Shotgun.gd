extends Node3D

signal shot_fired
signal reloaded

@onready var camera = $".."
@onready var player = $"../.."
@onready var raycast = $"../HitScan"
@onready var bob_max = position.y + BOB_OFFSET
@onready var bob_min = position.y - BOB_OFFSET
@onready var original_pos = position
@onready var original_rot = rotation
@onready var target_pos = original_pos
@onready var target_rot = original_rot
@onready var pump_original_pos = $Cube_004.position.x
@onready var pump_target_pos = $Cube_004.position.x - 0.4

const MAX_AMMO = 6
const RELOAD_TIME_PER_SHELL = 0.5
const PUMP_TIME = 0.5
const ADS_POS = Vector3(0, -0.15, -0.395)
const ADS_ROT = Vector3(0, 1.570796, 0)
const BOB_SPEED = 0.025
const BOB_OFFSET = 0.01

var ammo = MAX_AMMO
var damage = 3
var range = Vector3(1.0, 1.0, 50)
var is_reloading = false
var is_aiming = false
var ranged = true
var can_shoot = true 
var bob_up = true
var pump_animating = false
var pumping_back = true

func shoot():
	if is_reloading and ammo > 0:
		is_reloading = false
		player.can_switch = true
		pump()
	
	if ammo > 0 and can_shoot:
		player.can_switch = false
		can_shoot = false
		position.z += 0.2
		ammo -= 1
		
		muzzle_flash()
		hitscan()
		
		$ShotgunFire.play()
		await get_tree().create_timer(0.1).timeout
		pump()
		player.can_switch = true

func reload():
	if is_reloading or ammo >= MAX_AMMO:
		return
	
	is_reloading = true
	player.can_switch = false
	
	var was_aiming = false
	if is_aiming: 
		was_aiming = true
		aim()
	
	while ammo < MAX_AMMO and is_reloading:
		$ShotgunLoad.play()
		await get_tree().create_timer(RELOAD_TIME_PER_SHELL).timeout
		ammo += 1
	
	pump()
	
	is_reloading = false
	if was_aiming and not is_aiming: aim()
	emit_signal("reloaded")

func aim():
	if not is_aiming: 
		is_aiming = true
		target_pos = ADS_POS
		target_rot = ADS_ROT
	else:
		is_aiming = false
		target_pos = original_pos
		target_rot = original_rot

func hitscan():
	if not raycast.is_enabled():
		return
	
	var num_pellets = 8
	var spread_angle = 10
	
	for i in range(num_pellets):
		# Calculate the direction with a random spread
		var random_spread_x = randf_range(-spread_angle, spread_angle)
		var random_spread_y = randf_range(-spread_angle, spread_angle)
		var forward_dir = camera.global_transform.basis.z.normalized() * -1
		var right_dir = camera.global_transform.basis.x
		var up_dir = camera.global_transform.basis.y
		var spread_rot_x = deg_to_rad(random_spread_x)
		var spread_rot_y = deg_to_rad(random_spread_y)
		var pellet_direction = forward_dir.rotated(up_dir, spread_rot_x).rotated(right_dir, spread_rot_y)
		# Setup the ray query parameters
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.global_transform.origin
		ray_query.to = ray_query.from + pellet_direction * range.z  # Might need to adjust range.z for distance
		ray_query.collision_mask = 0xFFFFFFFF
		ray_query.collide_with_areas = true
		ray_query.collide_with_bodies = true
		# Perform the raycast
		var result = get_world_3d().direct_space_state.intersect_ray(ray_query)
		if result.size() != 0:  # If there is collision
			var collider = result.collider
			if collider and collider.has_method("apply_damage"):
				collider.apply_damage(damage)
				# Handle effects here, similar to your existing setup

func muzzle_flash():
	$MuzzleLight.show()
	await get_tree().create_timer(0.1).timeout
	$MuzzleLight.hide()

func pump():
	$ShotgunPump.play()
	pump_animating = true
	await get_tree().create_timer(PUMP_TIME).timeout
	can_shoot = true

func _process(delta):
	if not visible: pass
	
	if position.z > original_pos.z: 
		position.z = lerp(position.z, original_pos.z, 10.0 * delta)
	
	position.x = lerp(position.x, target_pos.x, 10.0 * delta)
	rotation = rotation.slerp(target_rot, 10.0 * delta)
	
	if pump_animating:
		var pump = $Cube_004 
		if pumping_back:
			if pump.position.x <= pump_target_pos: pumping_back = false
			$Cube_004.position.x -= 3.0 * delta
		else:
			if pump.position.x >= pump_original_pos:
				pumping_back = true
				pump_animating = false
			$Cube_004.position.x += 3.0 * delta
	
	if is_aiming:
		if pump_animating: 
			position.x = lerp(position.x, ADS_POS.x + 0.2, 10.0 * delta)
			rotation_degrees.x = lerp(rotation_degrees.x, 45.0, 10.0 * delta)
			position.y = lerp(position.y, ADS_POS.y - 0.1, 10.0 * delta)
		position.y = lerp(position.y, ADS_POS.y, 10.0 * delta)
	elif is_reloading: 
		position.y = lerp(position.y, -0.45, 10.0 * delta)
	elif position.y > original_pos.y + BOB_OFFSET: 
		position.y = lerp(position.y, original_pos.y + BOB_OFFSET, 10.0 * delta)
		bob_up = false
	elif position.y < original_pos.y - BOB_OFFSET: 
		position.y = lerp(position.y, original_pos.y - BOB_OFFSET, 10.0 * delta)
		bob_up = true

	var bob_speed
	if not $"../..".is_moving or $"../..".is_crouching:
		bob_speed = BOB_SPEED * 0.25
	elif $"../..".is_sprinting:
		bob_speed = BOB_SPEED * 1.5
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