extends CanvasLayer

@onready var main = $"Main Menu"
@onready var settings = $SettingsControl
@onready var audio = $Audio
@onready var video = $Video
@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_BUS = AudioServer.get_bus_index("SFX")

func _on_start_btn_pressed():
	var tween1 = get_tree().create_tween()
	tween1.tween_property($BlackScreen, "modulate", Color("ffffff", 1), 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property($AudioStreamPlayer, "volume_db", -20, 0.5)
	play_ui_audio(1.0)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_quit_btn_pressed():
	play_ui_audio(1.2)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _on_tutorial_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/Tutorials/MainControls.tscn")

func _ready():
	main.visible = true
	settings.visible = false
	audio.visible = false
	video.visible = false
	$BlackScreen.show()
	var tween = get_tree().create_tween()
	tween.tween_property($BlackScreen, "modulate", Color("ffffff", 0), 1.0)

func _on_settings_btn_pressed():
	play_ui_audio(1.0)
	main.visible = false
	settings.visible = true
	audio.visible = false
	video.visible = false
	
func _on_back_btn_pressed():
	play_ui_audio(0.8)
	main.visible = false
	settings.visible = true
	audio.visible = false
	video.visible = false
	
func _on_audio_setting_btn_pressed():
	play_ui_audio(1.2)
	main.visible= false
	audio.visible = true
	settings.visible = false
	video.visible = false
	
func _on_video_setting_btn_pressed():
	play_ui_audio(1.2)
	main.visible= false
	video.visible = true
	settings.visible = false
	audio.visible = false
	
func _on_main_menu_btn_pressed():
	play_ui_audio(0.8)
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
	play_ui_audio(0.9)
	main.visible= false
	video.visible = false
	settings.visible = true

func play_ui_audio(pitch):
	$UISound.set_pitch_scale(pitch)
	$UISound.play()
