extends Node3D

const BOB_SPEED = 0.025
const BOB_OFFSET = 0.01

var bob_max = 0.0
var bob_min = 0.0
var bob_up = true
var bob_ready = false
var on = false
var target_pos = -0.85

func _ready():
	bob_max = position.y + 0.02
	bob_min = position.y - 0.02
	position.y = target_pos

func toggle():
	bob_ready = false
	$Toggle.play()
	on = !on
	if on:
		$Light.show()
		target_pos = -0.4
	else: 
		target_pos = -0.85
		$Light.hide()

func _process(delta):
	if not bob_ready:
		position.y = lerp(position.y, target_pos, 5 * delta)
	
	if abs(position.y - target_pos) < 0.01:
		if not bob_ready: bob_ready = true
	
	if bob_ready:
		bob_max = target_pos + 0.01
		bob_min = target_pos - 0.01
		handle_bobbing(delta)

func handle_bobbing(delta):
	if not visible: return
	
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
