extends Node3D

var on = false
var target_pos = -0.85

func _ready():
	position.y = target_pos

func toggle():
	$Toggle.play()
	on = !on
	if on:
		$Light.show()
		target_pos = -0.4
	else: 
		target_pos = -0.85
		$Light.hide()

func _process(delta):
	if position.y == target_pos: 
		pass
	if position.y > target_pos: 
		position.y -= 1 * delta
	if position.y < target_pos: 
		position.y += 1 * delta
