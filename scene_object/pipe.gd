extends Node3D

# Pipe properties
@onready var camera = $".."
@onready var player = $"../.."
@onready var raycast = $"../HitScan"
var damage = 2
var range = Vector3(50.0, 50.0, 3)
var ranged = false
var is_swinging = false
var swing_duration = 0.4
var swing_timer = 0.0

# Temp animation variables
@onready var max_y = position.y + BOB_OFFSET
@onready var min_y = position.y - BOB_OFFSET
@onready var original_rotation_degrees = rotation_degrees
@onready var original_position = position
const ANIM_SPEED = 0.00025
const SWING_SPEED = 10.0
const BOB_OFFSET = 0.01
var swing_rotation_degrees = Vector3 (-65, 55, 0)
var swing_position = Vector3 (-0.761, -0.291, -1.093)
var going_up = true

func swing():
	if is_swinging:
		return 
	is_swinging = true
	player.can_switch = false
	swing_timer = swing_duration
	$Swing.play()
	if raycast.is_enabled():
		hitscan()

func hitscan():
	raycast.force_raycast_update()
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
	if is_swinging:
		if swing_timer > swing_duration / 2:
			rotation_degrees = rotation_degrees.lerp(swing_rotation_degrees, SWING_SPEED * delta)
			position = position.lerp(swing_position, SWING_SPEED* delta)
		else:
			rotation_degrees = rotation_degrees.lerp(original_rotation_degrees, SWING_SPEED * delta)
			position = position.lerp(original_position, SWING_SPEED * delta)
		swing_timer -= delta
		if swing_timer <= 0.0:
			is_swinging = false
			player.can_switch = true
			position = original_position
			rotation_degrees = original_rotation_degrees
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
