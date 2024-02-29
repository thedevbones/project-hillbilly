extends Node3D

# Pistol properties
@onready var camera = $".."
@onready var raycast = $"../HitScan"
const MAX_AMMO = 8
const RELOAD_TIME = 1.5
var ammo = MAX_AMMO
var damage = 1
var is_reloading = false

# Temp animation variables
@onready var max = position.y + 0.02
@onready var min = position.y - 0.02
@onready var original_pos_z = position.z
const ANIM_SPEED = 0.0005
var going_up = true

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
	if not is_reloading and ammo < MAX_AMMO:
		is_reloading = true
		$PistolReload.play()
		await get_tree().create_timer(RELOAD_TIME).timeout
		ammo = MAX_AMMO
		is_reloading = false
		emit_signal("reloaded")

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
	if not visible:
		pass
	if position.z > original_pos_z: position.z -= 0.01
	var anim_speed
	if not $"../..".is_moving or $"../..".is_crouching:
		anim_speed = ANIM_SPEED * 0.25
	elif $"../..".is_sprinting:
		anim_speed = ANIM_SPEED * 2
	else:
		anim_speed = ANIM_SPEED 
	if going_up:
		if position.y >= max: going_up = false
		position.y += anim_speed
	else:
		if position.y <= min: going_up = true
		position.y -= anim_speed
