extends Node3D

@onready var camera = $".."
@onready var player = $"../.."
@onready var raycast = $"../HitScan"
@onready var original_rotation_degrees = rotation_degrees
@onready var original_position = position
@onready var bob_max = position.y + BOB_OFFSET
@onready var bob_min = position.y - BOB_OFFSET

const BOB_SPEED = 0.025
const SWING_SPEED = 10.0
const BOB_OFFSET = 0.01

var damage = 1
var range = Vector3(50.0, 50.0, 2)
var ranged = false
var is_swinging = false
var swing_duration = 0.2
var swing_timer = 0.0
var swing_rotation_degrees = Vector3 (-0, -140,55.5)
var swing_position = Vector3 (-1.0, -0.25, -0.55)
var bob_up = true

func swing():
	if is_swinging:
		return 
	
	is_swinging = true
	player.can_switch = false
	
	swing_timer = swing_duration
	$Swing.play()
	hitscan()

func hitscan():
	if not raycast.is_enabled():
		return
	
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
