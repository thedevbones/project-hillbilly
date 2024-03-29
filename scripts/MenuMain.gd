extends CanvasLayer

@onready var main = $"Main Menu"
@onready var settings = $SettingsControl
@onready var audio = $Audio
@onready var video = $Video
@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_BUS = AudioServer.get_bus_index("SFX")

func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_tutorial_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuTutorial.tscn")

func _ready():
	main.visible = true
	settings.visible = false
	audio.visible = false
	video.visible = false
	
func _on_settings_btn_pressed():
	main.visible = false
	settings.visible = true
	audio.visible = false
	video.visible = false
	
func _on_back_btn_pressed():
	main.visible = false
	settings.visible = true
	audio.visible = false
	video.visible = false
	
func _on_audio_setting_btn_pressed():
	main.visible= false
	audio.visible = true
	settings.visible = false
	video.visible = false
	
func _on_video_setting_btn_pressed():
	main.visible= false
	video.visible = true
	settings.visible = false
	audio.visible = false
	
func _on_main_menu_btn_pressed():
	main.visible= true
	video.visible = false
	settings.visible = false
	audio.visible = false
	
func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(value)) 
	AudioServer.set_bus_mute(MASTER_BUS, value < .05)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(value)) 
	AudioServer.set_bus_mute(MUSIC_BUS, value < .05)

func _on_sound_fx_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(value)) 
	AudioServer.set_bus_mute(SFX_BUS, value < .05)

func _on_check_box_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_btn_2_pressed():
	main.visible= false
	video.visible = false
	settings.visible = true

