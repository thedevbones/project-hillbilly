extends CanvasLayer

@onready var main = $"Main Menu"
@onready var settings = $SettingsControl
@onready var audio = $Audio
@onready var video = $Video
@onready var tutorialMove = $Tutorial_Movement
@onready var turotialAtk = $Tutorial_Attack
@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_BUS = AudioServer.get_bus_index("SFX")

func _on_start_btn_pressed():
	var tween1 = get_tree().create_tween()
	tween1.tween_property($BlackScreen, "modulate", Color("ffffff", 1), 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property($AudioStreamPlayer, "volume_db", -20, 0.5)
	play_ui_audio(0.1)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_quit_btn_pressed():
	play_ui_audio(0.2)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _ready():
	main.visible = true
	settings.visible = false
	audio.visible = false
	video.visible = false
	tutorialMove.visible = false
	turotialAtk.visible = false
	$BlackScreen.show()
	var tween = get_tree().create_tween()
	tween.tween_property($BlackScreen, "modulate", Color("ffffff", 0), 1.0)

func _on_settings_btn_pressed():
	play_ui_audio(0.2)
	main.visible = false
	settings.visible = true
	audio.visible = false
	video.visible = false
	
func _on_back_btn_pressed():
	play_ui_audio(0.2)
	main.visible = false
	settings.visible = true
	audio.visible = false
	video.visible = false
	
func _on_tutorial_btn_pressed():
	play_ui_audio(0.2)
	main.visible = false
	tutorialMove.visible = true
	turotialAtk.visible = false
	
func _on_audio_setting_btn_pressed():
	play_ui_audio(0.2)
	main.visible= false
	audio.visible = true
	settings.visible = false
	video.visible = false
	
func _on_video_setting_btn_pressed():
	play_ui_audio(0.2)
	main.visible= false
	video.visible = true
	settings.visible = false
	audio.visible = false
	
func _on_main_menu_btn_pressed():
	play_ui_audio(0.2)
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

func _on_fullscreen_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_btn_2_pressed():
	play_ui_audio(0.2)
	main.visible= false
	video.visible = false
	settings.visible = true

func play_ui_audio(pitch):
	$UISound.set_pitch_scale(1)
	$UISound.play()

func _on_main_menu_pressed():
	play_ui_audio(0.2)
	main.visible = true
	tutorialMove.visible = false
	turotialAtk.visible= false

func _on_attack_controls_pressed():
	play_ui_audio(0.2)
	main.visible = false
	tutorialMove.visible = false
	turotialAtk.visible= true
	
func _on_main_controls_pressed():
	play_ui_audio(0.2)
	main.visible = false
	tutorialMove.visible = true
	turotialAtk.visible= false

func _on_ssao_check_box_toggled(toggled_on):
	Graphics.update_ssao(toggled_on)

func _on_ssil_check_box_2_toggled(toggled_on):
	Graphics.update_ssil(toggled_on)

func _on_grass_check_box_toggled(toggled_on):
	Graphics.update_grass(toggled_on)

func _on_demo_btn_pressed():
	Graphics.demo_mode = true

	var tween2 = get_tree().create_tween()
	tween2.tween_property($AudioStreamPlayer, "volume_db", -20, 0.5)
	play_ui_audio(0.1)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/IntroScene.tscn")

func _input(event):
	if event.is_action_pressed("reload"):
		$"Main Menu/MarginContainer/VBoxContainer/StartBtn".disabled = false
