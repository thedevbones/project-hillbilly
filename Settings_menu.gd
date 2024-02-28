extends CanvasLayer

@onready var settings = $SettingsControl
@onready var audio = $Audio

func _ready():
	settings.visible = true
	audio.visible = false

func _on_main_menu_btn_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_back_btn_pressed():
	settings.visible = true
	audio.visible = false

func _on_audio_setting_btn_pressed():
	audio.visible = true
	settings.visible = false
