extends Node3D

# Pistol properties
@onready var camera = $".."
@onready var raycast = $"../HitScan"
const MAX_AMMO = 6
const RELOAD_TIME_PER_SHELL = 0.5
const COCK_TIME = 0.5
var ammo = MAX_AMMO
var damage = 3
var is_reloading = false
var is_aiming = false
var ranged = true
var can_shoot = true 

# Temp animation variables
@onready var max_y = position.y + BOB_OFFSET
@onready var min_y = position.y - BOB_OFFSET
@onready var original_pos = position
@onready var original_rot = rotation
const ADS_POS = Vector3(0, -0.15, -0.395)
const ADS_ROT = Vector3(0, 1.570796, 0)
const ANIM_SPEED = 0.00025
const BOB_OFFSET = 0.01
var going_up = true
@onready var target_pos = original_pos
@onready var target_rot = original_rot

# Signals
signal shot_fired
signal reloaded

func shoot():
	if ammo > 0 and not is_reloading and can_shoot:
		can_shoot = false
		position.z += 0.2
		$ShotgunFire.play()
		$MuzzleLight.show()
		await get_tree().create_timer(0.1).timeout
		$MuzzleLight.hide()
		if raycast.is_enabled():
			hitscan()
		ammo -= 1
		$ShotgunCock.play(0.0)
		await get_tree().create_timer(COCK_TIME).timeout
		can_shoot = true # Allow shooting again

func reload():
	if is_reloading or ammo >= MAX_AMMO:
		return
	is_reloading = true
	while ammo < MAX_AMMO:
		$ShotgunLoad.play()
		await get_tree().create_timer(RELOAD_TIME_PER_SHELL).timeout
		ammo += 1
	$ShotgunCock.play()
	await get_tree().create_timer(COCK_TIME).timeout
	is_reloading = false
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
		position.y = lerp(position.y, ADS_POS.y, 10.0 * delta)
		pass
	elif position.y > original_pos.y + BOB_OFFSET: 
		position.y = lerp(position.y, original_pos.y + BOB_OFFSET, 10.0 * delta)
		going_up = false
		pass
	var anim_speed
	if not $"../..".is_moving or $"../..".is_crouching:
		anim_speed = ANIM_SPEED * 0.25
	elif $"../..".is_sprinting:
		anim_speed = ANIM_SPEED * 1.5
	else:
		anim_speed = ANIM_SPEED 
	if going_up:
		if position.y >= max_y: going_up = false
		position.y += anim_speed
	else:
		if position.y <= min_y: going_up = true
		position.y -= anim_speed
