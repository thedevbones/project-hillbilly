extends Node3D

# Pipe properties
@onready var camera = $".."
@onready var raycast = $"../HitScan"
var damage = 1
var range = Vector3(50.0, 50.0, 3)
var ranged = false

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

func swing():
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
