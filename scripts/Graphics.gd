extends Node

var graphics: Environment
var grass

func update_ssao(toggle):
	graphics.set_ssao_enabled(toggle)

func update_ssil(toggle):
	graphics.set_ssil_enabled(toggle)

func update_grass(toggle):
	grass.visible = toggle
