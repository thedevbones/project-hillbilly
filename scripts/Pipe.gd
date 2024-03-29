extends "res://scripts/Weapon.gd"

const SWING_SPEED = 10.0
const BOB_SPEED = 0.025
const BOB_OFFSET = 0.01

@onready var original_rotation_degrees = rotation_degrees
@onready var original_position = position
var swing_rotation_degrees = Vector3 (-95, 55, 5)
var swing_position = Vector3 (-0.9, -0.4, -1.093)

func _ready():
	damage = 2
	range = Vector3(50.0, 50.0, 3)
	ranged = false  # Important to note that this is a melee weapon
	original_pos = position
	original_rot = rotation
	bob_max = position.y + BOB_OFFSET
	bob_min = position.y - BOB_OFFSET
	swing_duration = 0.4  # Assuming you want to keep melee-specific timings

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
