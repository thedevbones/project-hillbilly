extends Node

var graphics: Environment
var grass
var player : CharacterBody3D 
var grass_visible = true
var demo_mode = false
var bobbing = true
var swaying = true
var max_enemies = 20
var max_decals = 30
var in_game = false
var tutorials = true
var blood = false
var sensitivity = 0.2

func update_ssao(toggle):
	graphics.set_ssao_enabled(toggle)

func update_ssil(toggle):
	graphics.set_ssil_enabled(toggle)

func update_grass(toggle):
	grass.visible = toggle
	grass_visible = toggle

func update_swaying(toggle):
	swaying = toggle

func update_bobbing(toggle):
	bobbing = toggle

func update_blood(toggle):
	blood = toggle

func set_brightness(value):
	graphics.adjustment_brightness = value

func set_max_enemies(value):
	max_enemies = value

func set_max_decals(value):
	max_decals = value

func set_sensitivity(value):
	sensitivity = value
	if player: player.mouse_sensitivity = value

func get_ssao():
	return graphics.is_ssao_enabled()

func get_ssil():
	return graphics.is_ssao_enabled()

func get_grass():
	return grass_visible

func get_brightness():
	return graphics.adjustment_brightness

func get_max_enemies():
	return max_enemies

func get_max_decals():
	return max_decals

func get_sensitivity():
	return sensitivity

func get_blood():
	return blood
