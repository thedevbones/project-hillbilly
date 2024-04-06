extends Node

var graphics: Environment
var grass
var grass_visible = true
var demo_mode = false

func update_ssao(toggle):
	graphics.set_ssao_enabled(toggle)

func update_ssil(toggle):
	graphics.set_ssil_enabled(toggle)

func update_grass(toggle):
	grass.visible = toggle
	grass_visible = toggle

func get_ssao():
	return graphics.is_ssao_enabled()

func get_ssil():
	return graphics.is_ssao_enabled()

func get_grass():
	return grass_visible

