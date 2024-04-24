extends Control

@onready var main = $"Main Menu"
@onready var settings = $SettingsControl
@onready var audio = $Audio
@onready var video = $Video
@onready var tutorialMove = $Tutorial_Movement
@onready var turotialAtk = $Tutorial_Attack
@onready var resolutionOptions = $Video/MarginContainer2/HBoxContainer/Sliders/ResolutionOptionButton
@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_BUS = AudioServer.get_bus_index("SFX")

var gui
var is_paused = false
var background_scene = preload("res://scenes/Background.tscn")

func _on_start_btn_pressed():
	Graphics.in_game = true
	# var tween1 = get_tree().create_tween()
	# tween1.tween_property($BlackScreen, "modulate", Color("ffffff", 1), 0.5)
	var tween2 = get_tree().create_tween()
	tween2.tween_property($AudioStreamPlayer, "volume_db", -20, 0.5)
	play_ui_audio(0.1)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/IntroScene.tscn")

func _on_quit_btn_pressed():
	Graphics.in_game = false
	play_ui_audio(0.2)
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _ready():
	main.visible = !Graphics.in_game
	settings.visible = false
	audio.visible = false
	video.visible = false
	tutorialMove.visible = false
	turotialAtk.visible = false
	init_resolutions()
	adjust_buttons()
	if not Graphics.in_game:
		$BlackScreen.show()
		var tween = get_tree().create_tween()
		tween.tween_property($BlackScreen, "modulate", Color("ffffff", 0), 1.0)
		var background = background_scene.instantiate()
		add_child(background)
		$AudioStreamPlayer.play()
	gui = get_node_or_null("/root/World/UI")

func adjust_buttons():
	$"Main Menu/MarginContainer/VBoxContainer/StartBtn".visible = !Graphics.in_game
	#$"Main Menu/MarginContainer/VBoxContainer/DemoBtn".visible = !Graphics.in_game
	$"Main Menu/MarginContainer/VBoxContainer/Resume".visible = Graphics.in_game
	$"Main Menu/MarginContainer/VBoxContainer/ReturnMainMenuBtn".visible = Graphics.in_game

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

#func _on_demo_btn_pressed():
	#Graphics.demo_mode = true
	#_on_start_btn_pressed()

func _input(event):
	if event.is_action_pressed("reload"):
		$"Main Menu/MarginContainer/VBoxContainer/StartBtn".disabled = false
	if event.is_action_pressed("ui_cancel") and Graphics.in_game:
		toggle_pause()

func init_resolutions():
	var resolutions = [
		# 4:3 aspect ratio
		"640x480 (SD, 4:3)",
		"800x600 (SVGA, 4:3)",
		"1024x768 (XGA, 4:3)",
		"1600x1200 (UXGA, 4:3)",
		# 16:9 aspect ratio
		"1280x720 (HD, 16:9)",
		"1600x900 (HD+, 16:9)",
		"1920x1080 (Full HD, 16:9)",
		"2560x1440 (QHD, 16:9)",
		"3840x2160 (UHD, 16:9)",
		# 21:9 aspect ratio
		"2560x1080 (UW-UXGA, 21:9)",
		"3440x1440 (UW-QHD, 21:9)",
		"5120x2160 (UW5K, 21:9)"
	]
	
	for resolution in resolutions:
		resolutionOptions.add_item(resolution)
	
	resolutionOptions.selected = 4

func _on_resolution_option_button_item_selected(index): 
	var resolution_sizes = [
		Vector2(640, 480),   # 4:3 SD
		Vector2(800, 600),   # 4:3 SVGA
		Vector2(1024, 768),  # 4:3 XGA
		Vector2(1600, 1200), # 4:3 UXGA
		Vector2(1280, 720),  # 16:9 HD
		Vector2(1600, 900),  # 16:9 HD+
		Vector2(1920, 1080), # 16:9 Full HD
		Vector2(2560, 1440), # 16:9 QHD
		Vector2(3840, 2160), # 16:9 UHD
		Vector2(2560, 1080), # 21:9 UW-UXGA
		Vector2(3440, 1440), # 21:9 UW-QHD
		Vector2(5120, 2160)  # 21:9 UW5K
	]
	DisplayServer.window_set_size(resolution_sizes[index])

func _on_bright_slider_value_changed(value):
	Graphics.set_brightness(value * 2)

func _on_max_enemies_slider_value_changed(value):
	Graphics.set_max_enemies(value)

func _on_max_decals_slider_value_changed(value):
	Graphics.set_max_decals(value)

func _on_sway_check_box_toggled(toggled_on):
	Graphics.update_swaying(toggled_on)

func _on_bob_check_box_toggled(toggled_on):
	Graphics.update_bobbing(toggled_on)

func toggle_pause():
	if is_paused:
		unpause_game()
	else:
		pause_game()

func unpause_game():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	if gui: gui.show()
	is_paused = false
	
func pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	if gui: gui.hide()
	is_paused = true
	main.visible = true
	settings.visible = false
	audio.visible = false
	video.visible = false
	tutorialMove.visible = false
	turotialAtk.visible = false


func _on_resume_pressed():
	unpause_game()

func _on_return_main_menu_btn_pressed():
	unpause_game()
	Graphics.in_game = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")


func _on_sensitivity_value_changed(value):
	Graphics.set_sensitivity(value)


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()


func _on_blood_check_box_toggled(toggled_on):
	Graphics.update_blood(toggled_on)
