extends Node3D

signal shot_fired
signal reloaded

@onready var camera = $".."
@onready var player = $"../.."
@onready var raycast = $"../HitScan"
@onready var original_pos = position
@onready var original_rot = rotation
@onready var target_pos = original_pos
@onready var target_rot = original_rot
@onready var bob_max = position.y + 0.02
@onready var bob_min = position.y - 0.02

const MAX_AMMO = 8
const RELOAD_TIME = 1.5
const ADS_POS = Vector3(0, -0.4, -1.058)
const ADS_ROT = Vector3(0, 0, 0)
const BOB_SPEED = 0.05

var ammo = MAX_AMMO
var damage = 1
var range = Vector3(1.0, 1.0, 100)
var is_reloading = false
var is_aiming = false
var ranged = true
var bob_up = true

func shoot():
	if ammo > 0 and not is_reloading:
		player.can_switch = false
		position.z += 0.2
		$PistolFire.play()
		muzzle_flash()
		hitscan()
		ammo -= 1
		player.can_switch = true

func reload():
	var was_aiming = false
	if not is_reloading and ammo < MAX_AMMO:
		is_reloading = true
		player.can_switch = false
		
		if is_aiming: 
			was_aiming = true
			aim()
		
		$PistolReload.play()
		await get_tree().create_timer(RELOAD_TIME).timeout
		
		ammo = MAX_AMMO
		is_reloading = false
		player.can_switch = true
		emit_signal("reloaded")
		if was_aiming and not is_aiming: aim()

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
	
	raycast.force_raycast_update()  # Updates the raycast immediately
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_method("apply_damage"):
			collider.apply_damage(damage)
			# NOTE: followig code is unused atm but will be used for FX
			# var collision_point = raycast.get_collision_point()
			# var collision_normal = raycast.get_collision_normal()
			# Call a function to create FX
			# emit_signal("shot_fired", collision_point, collision_normal)

func muzzle_flash():
	$MuzzleLight.show()
	await get_tree().create_timer(0.1).timeout
	$MuzzleLight.hide()

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
