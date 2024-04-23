extends Node3D

signal shot_fired
signal reloaded

# Weapon variables
var damage = 1
var ammo = 0
var max_ammo = 0
var total_ammo = 0
var reload_time = 1
var range = Vector3.ZERO
var is_reloading = false
var is_aiming = false
var is_blocking = false
var ranged = true
var is_swinging = false
var swing_duration = 0.4
var swing_timer = 0.0
var bob_up = true
var weapon_recoil = 2.0

# Weapon references
@onready var player = %Player
@onready var raycast = $"../HitScan"
@onready var camera = $".."
@onready var bob_max = position.y + 0.02
@onready var bob_min = position.y - 0.02
var fire_sound: AudioStreamPlayer3D
var reload_sound: AudioStreamPlayer3D
var target_pos: Vector3
var target_rot: Vector3
var ads_pos: Vector3
var ads_rot: Vector3
var block_pos: Vector3
var block_rot: Vector3
var original_pos: Vector3
var original_rot: Vector3
var weapon_type
var bullet_decal = preload("res://scenes/BulletDecal.tscn")
var blood_decal = preload("res://scenes/BloodDecal.tscn")
var object_particle = preload("res://scenes/ParticlesObjectHit.tscn")
var enemy_particle = preload("res://scenes/ParticlesEnemyHit.tscn")


func _ready():
	pass

func swing():
	if is_swinging or is_blocking: return 
	
	is_swinging = true
	player.can_switch = false
	
	swing_timer = swing_duration
	$Swing.play()
	hitscan()

func shoot():
	if ammo > 0 and not is_reloading:
		player.can_switch = false
		position.z += 0.2
		camera.recoil(weapon_recoil)
		fire_sound.play()
		muzzle_flash()
		hitscan()
		ammo -= 1
		player.can_switch = true
		%UI.update_ammo_count()

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

	reload_sound.play()
	await get_tree().create_timer(reload_time).timeout
	var ammo_needed = max_ammo - ammo
	var ammo_to_load = min(ammo_needed, total_ammo)

	ammo += ammo_to_load
	player.add_ammo(weapon_type, -ammo_to_load)

	is_reloading = false
	player.can_switch = true
	emit_signal("reloaded")
	%UI.update_ammo_count()
	if was_aiming and not is_aiming: aim()

func aim():
	if not is_aiming: 
		is_aiming = true
		target_pos = ads_pos
		target_rot = ads_rot
	else:
		is_aiming = false
		target_pos = original_pos
		target_rot = original_rot
	%UI.update_crosshair()

func block():
	if player.block_hits <= 0:
		is_blocking = false
		player.blocking = false
		target_pos = original_pos
		target_rot = original_rot
		return
	if not is_blocking:
		is_blocking = true
		player.blocking = true
		target_pos = block_pos
		target_rot = block_rot
	else:
		is_blocking = false
		player.blocking = false
		target_pos = original_pos
		target_rot = original_rot

func hitscan():
	if not raycast.is_enabled():
		return
	raycast.force_raycast_update()  # Updates the raycast immediately
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider:
			var collision_point = raycast.get_collision_point()
			var collision_normal = raycast.get_collision_normal()
			var hit_particle = object_particle.instantiate()
			var hit_damage = bullet_decal.instantiate()
			
			if collider.name == "Moon":
				collider.reveal()
				return
			elif collider.name == "Light":
				collider.destroy()
			if collider is PhysicalBone3D: 
				var enemy = collider
				while enemy and not enemy.has_method("apply_damage"):
					enemy = enemy.get_parent()
				if enemy and enemy.has_method("apply_damage"):
					var damage_multiplier = 1.0
					if collider.name == "Head":
						damage_multiplier = randf_range(1.25, 2.5)
					enemy.apply_damage(damage * damage_multiplier)
				if Graphics.blood:
					hit_particle = enemy_particle.instantiate()
					hit_damage = blood_decal.instantiate()
			hit_particle.global_position = collision_point
			get_tree().current_scene.add_child(hit_particle)
			hit_particle.look_at(collision_point + collision_normal, Vector3.UP)
			hit_particle.look_at(collision_point + collision_normal, Vector3.RIGHT)
			
			collider.add_child(hit_damage)
			hit_damage.global_position = collision_point
			hit_damage.look_at(collision_point + collision_normal, Vector3.UP)
			hit_damage.look_at(collision_point + collision_normal, Vector3.RIGHT)
			
			if collider is RigidBody3D:
				collider.apply_damage(collision_point, collision_normal, 10000) 
			

func muzzle_flash():
	$MuzzleLight.show()
	await get_tree().create_timer(0.1).timeout
	$MuzzleLight.hide()

func _process(delta):
	pass
