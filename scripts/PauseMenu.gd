extends ColorRect

var is_paused = false

@onready var ResumeBtn: Button = find_child("ResumeBtn")
@onready var QuitBtn: Button = find_child("QuitBtn")
@onready var MenuBtn: Button = find_child("MenuBtn")
@onready var InMain = $PauseMain
@onready var InSetting = $PauseSetting
@onready var InAudio = $PauseAudio
@onready var InVideo = $PausedVideo
@onready var Tutorial_Move = $Tutorial_Movement
@onready var Turorial_Atk = $Tutorial_Attack
@onready var MASTER_BUS = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS = AudioServer.get_bus_index("Music")
@onready var SFX_BUS = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	ResumeBtn.pressed.connect(unpause_game)
	QuitBtn.pressed.connect(get_tree().quit)
	MenuBtn.pressed.connect(mainMenu)
	InMain.visible = true
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = false
	Tutorial_Move.visible = false
	Turorial_Atk.visible = false
	
func _input(event):	
	# Handle pressing esc
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	
func toggle_pause():
	if is_paused:
		unpause_game()
	else:
		pause_game()

func unpause_game():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	is_paused = false
	
func pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	is_paused = true
	InMain.visible = true
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = false
	Tutorial_Move.visible = false
	Turorial_Atk.visible = false
	
func mainMenu():
	unpause_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")
	
func _on_settings_btn_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	InSetting.visible = true
	
func _on_tutorial_btn_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	Tutorial_Move.visible = true
	Turorial_Atk.visible = false
	
func _on_return_menu_pressed():
	play_ui_audio(0.2)
	InMain.visible = true
	Tutorial_Move.visible = false
	

func _on_in_audio_setting_btn_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	InSetting.visible = false
	InAudio.visible = true

func _on_in_video_setting_btn_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = true

func _on_back_pause_btn_pressed():
	play_ui_audio(0.2)
	InMain.visible = true
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = false

func _on_back_setting_btn_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	InSetting.visible = true
	InAudio.visible = false
	InVideo.visible = false

func _on_back_setting_btn_2_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	InSetting.visible = true
	InAudio.visible = false
	InVideo.visible = false

func _on_in_game_check_box_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(value)) 
	AudioServer.set_bus_mute(MASTER_BUS, value < .05)

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(value)) 
	AudioServer.set_bus_mute(MUSIC_BUS, value < .05)

func _on_sound_fx_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(value)) 
	AudioServer.set_bus_mute(SFX_BUS, value < .05)

func play_ui_audio(pitch):
	$UISound.set_pitch_scale(pitch)
	$UISound.play()

func _on_attack_controls_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	Tutorial_Move.visible = false
	Turorial_Atk.visible = true

func _on_main_controls_pressed():
	play_ui_audio(0.2)
	InMain.visible = false
	Tutorial_Move.visible = true
	Turorial_Atk.visible = false
	
func _on_return_menu_2_pressed():
	play_ui_audio(0.2)
	InMain.visible = true
	Tutorial_Move.visible = false
	Turorial_Atk.visible = false

func _on_ssao_check_box_toggled(toggled_on):
	Graphics.update_ssao(!toggled_on)

func _on_ssil_check_box_2_toggled(toggled_on):
	Graphics.update_ssil(!toggled_on)

func _on_grass_check_box_toggled(toggled_on):
	Graphics.update_grass(!toggled_on)
