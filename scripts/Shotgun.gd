extends "res://scripts/Weapon.gd"

const ADS_POS = Vector3(0, -0.15, -0.395)
const ADS_ROT = Vector3(0, 1.570796, 0)
const PUMP_TIME = 0.5
const RELOAD_TIME_PER_SHELL = 0.5
const MAX_AMMO = 6
const BOB_SPEED = 0.025
const BOB_OFFSET = 0.01
var pump_target_pos: float
var pump_original_pos: float
var can_shoot: bool = true
var pump_animating: bool = false
var pumping_back: bool = true

func _ready():
	weapon_type = player.Weapons.SHOTGUN
	damage = 3
	max_ammo = MAX_AMMO
	ammo = max_ammo
	reload_time = RELOAD_TIME_PER_SHELL
	range = Vector3(1.0, 1.0, 50)
	ranged = true
	original_pos = position
	original_rot = rotation
	target_pos = original_pos
	target_rot = original_rot
	ads_pos = ADS_POS
	ads_rot = ADS_ROT
	fire_sound = $ShotgunFire
	reload_sound = $ShotgunLoad
	pump_original_pos = $Cube_004.position.x
	pump_target_pos = $Cube_004.position.x - 0.4
	weapon_recoil = 5.0

func shoot():
	if is_reloading and ammo > 0:
		is_reloading = false
		player.can_switch = true
		pump()
	
	if ammo > 0 and can_shoot:
		player.can_switch = false
		can_shoot = false
		position.z += 0.2
		camera.recoil(weapon_recoil)
		ammo -= 1
		
		muzzle_flash()
		hitscan()
		
		%UI.update_ammo_count()
		$ShotgunFire.play()
		await get_tree().create_timer(0.1).timeout
		pump()
		player.can_switch = true

func reload():
	if is_reloading or ammo >= max_ammo: return

	var total_ammo = player.get_ammo(weapon_type)
	if total_ammo == 0: return
	is_reloading = true
	player.can_switch = false
	
	var was_aiming = false
	if is_aiming: 
		was_aiming = true
		aim()

	while ammo < max_ammo and total_ammo > 0 and is_reloading:
		$ShotgunLoad.play()
		await get_tree().create_timer(reload_time).timeout
		ammo += 1
		player.add_ammo(weapon_type, -1)
		%UI.update_ammo_count()
	
	pump() 
	is_reloading = false
	player.can_switch = true
	emit_signal("reloaded")

	if was_aiming and not is_aiming:
		aim()


func hitscan():
	if not raycast.is_enabled():
		return
	
	var num_pellets = 6
	var spread_angle = 10
	
	for i in range(num_pellets):
		# Calculate direction with random spread
		var random_spread_x = randf_range(-spread_angle, spread_angle)
		var random_spread_y = randf_range(-spread_angle, spread_angle)
		var forward_dir = camera.global_transform.basis.z.normalized() * -1
		var right_dir = camera.global_transform.basis.x
		var up_dir = camera.global_transform.basis.y
		var spread_rot_x = deg_to_rad(random_spread_x)
		var spread_rot_y = deg_to_rad(random_spread_y)
		var pellet_direction = forward_dir.rotated(up_dir, spread_rot_x).rotated(right_dir, spread_rot_y)
		# Setup ray query parameters
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.global_transform.origin
		ray_query.to = ray_query.from + pellet_direction * range.z
		ray_query.collision_mask = 0x0004 # Layer 3
		ray_query.collide_with_areas = true
		ray_query.collide_with_bodies = true
		# Perform raycast
		var result = get_world_3d().direct_space_state.intersect_ray(ray_query)
		if result.size() != 0:  # If collision
			var collider = result.collider
			if collider:
				var collision_point = result.position
				var collision_normal = result.normal
				var hit_particle = object_particle.instantiate()
				var hit_damage = bullet_decal.instantiate()
				
				if collider is PhysicalBone3D: 
					hit_particle = enemy_particle.instantiate()
					hit_damage = blood_decal.instantiate()
					var enemy = collider
					while enemy and not enemy.has_method("apply_damage"):
						enemy = enemy.get_parent()
					if enemy and enemy.has_method("apply_damage"):
						var damage_multiplier = 1.0
						if collider.name == "Head":
							damage_multiplier = randf_range(1.25, 2.5)
						enemy.apply_damage(damage * damage_multiplier)
				
				if collider is RigidBody3D:
					collider.apply_damage(collision_point, collision_normal, 11000) 
				
				hit_particle.global_position = collision_point
				get_tree().current_scene.add_child(hit_particle)
				hit_particle.look_at(collision_point + collision_normal, Vector3.UP)
				hit_particle.look_at(collision_point + collision_normal, Vector3.RIGHT)
				
				collider.add_child(hit_damage)
				hit_damage.global_position = collision_point
				hit_damage.look_at(collision_point + collision_normal, Vector3.UP)

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
	if not %Player.is_moving or %Player.is_crouching:
		bob_speed = BOB_SPEED * 0.25
	elif %Player.is_sprinting:
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
