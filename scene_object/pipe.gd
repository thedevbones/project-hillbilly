extends Node3D

# Pipe properties
@onready var camera = $".."
@onready var raycast = $"../HitScan"
var damage = 2
var range = Vector3(50.0, 50.0, 3)
var ranged = false
var is_swinging = false
var swing_duration = 0.4 # Duration of the swing in seconds
var swing_timer = 0.0 # Timer to track the swing progress

# Temp animation variables
@onready var max_y = position.y + BOB_OFFSET
@onready var min_y = position.y - BOB_OFFSET
@onready var original_rotation_degrees = rotation_degrees
@onready var original_position = position
const ANIM_SPEED = 0.00025
const BOB_OFFSET = 0.01
var swing_rotation_degrees = Vector3 (-65, 55, 0) # Adjust as needed
var swing_position = Vector3 (-0.761, -0.291, -1.093) # Adjust as needed
var going_up = true

func swing():
	if is_swinging:
		return # Prevent starting a new swing while already swinging
	is_swinging = true
	swing_timer = swing_duration
	$Swing.play()
	if raycast.is_enabled():
		hitscan()

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
	if is_swinging:
		if swing_timer > swing_duration / 2:
			# Swing forward
			rotation_degrees = rotation_degrees.lerp(swing_rotation_degrees, 0.1)
			position = position.lerp(swing_position, 0.1)
		else:
			# Return to original rotation
			rotation_degrees = rotation_degrees.lerp(original_rotation_degrees, 0.1)
			position = position.lerp(original_position, 0.1)
		swing_timer -= delta
		if swing_timer <= 0.0:
			is_swinging = false
			rotation_degrees = original_rotation_degrees # Ensure it's exactly the original rotation after swing
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
