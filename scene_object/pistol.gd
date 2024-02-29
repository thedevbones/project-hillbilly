extends Node3D

# Pistol properties
@onready var camera = $".."
@onready var raycast = $"../HitScan"
const MAX_AMMO = 8
const RELOAD_TIME = 1.5
var ammo = MAX_AMMO
var damage = 1
var range = Vector3(1.0, 1.0, 100)
var is_reloading = false
var is_aiming = false
var ranged = true

# Temp animation variables
@onready var max_y = position.y + 0.02
@onready var min_y = position.y - 0.02
@onready var original_pos = position
@onready var original_rot = rotation
const ADS_POS = Vector3(0, -0.4, -1.058)
const ADS_ROT = Vector3(0, 0, 0)
const ANIM_SPEED = 0.0005
var going_up = true
@onready var target_pos = original_pos
@onready var target_rot = original_rot

# Signals
signal shot_fired
signal reloaded

func shoot():
	if ammo > 0 and not is_reloading:
		position.z += 0.2
		# Play fire sound
		$PistolFire.play()
		# Flash muzzle flash light
		$MuzzleLight.show()
		await get_tree().create_timer(0.1).timeout
		$MuzzleLight.hide()
		if raycast.is_enabled():
			hitscan()
		# Adjust ammo
		ammo -= 1

func reload():
	var was_aiming = false
	if not is_reloading and ammo < MAX_AMMO:
		is_reloading = true
		if is_aiming: 
			was_aiming = true
			aim()
		$PistolReload.play()
		await get_tree().create_timer(RELOAD_TIME).timeout
		ammo = MAX_AMMO
		is_reloading = false
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

# Temp animation
func _process(delta):
	if not visible: pass
	if position.z > original_pos.z: position.z -= 0.01
	position.x = lerp(position.x, target_pos.x, 10.0 * delta)
	rotation = rotation.slerp(target_rot, 10.0 * delta)
	if is_aiming:
		position.y = lerp(position.y, -0.2, 10.0 * delta)
	elif is_reloading: 
		position.y = lerp(position.y, -0.6, 10.0 * delta)
	elif position.y > -0.38: 
		position.y = lerp(position.y, -0.38, 10.0 * delta)
		going_up = false
	elif position.y < -0.42: 
		position.y = lerp(position.y, -0.42, 10.0 * delta)
		going_up = true
	var anim_speed
	if not $"../..".is_moving or $"../..".is_crouching:
		anim_speed = ANIM_SPEED * 0.25
	elif $"../..".is_sprinting:
		anim_speed = ANIM_SPEED * 2
	else:
		anim_speed = ANIM_SPEED 
	if going_up:
		if position.y >= max_y: going_up = false
		position.y += anim_speed
	else:
		if position.y <= min_y: going_up = true
		position.y -= anim_speed
