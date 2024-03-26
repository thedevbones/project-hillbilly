extends ColorRect

var is_paused = false

@onready var ResumeBtn: Button = find_child("ResumeBtn")
@onready var QuitBtn: Button = find_child("QuitBtn")
@onready var MenuBtn: Button = find_child("MenuBtn")
@onready var InMain = $PauseMain
@onready var InSetting = $PauseSetting
@onready var InAudio = $PauseAudio
@onready var InVideo = $PausedVideo

func _ready() -> void:
	ResumeBtn.pressed.connect(unpause_game)
	QuitBtn.pressed.connect(get_tree().quit)
	MenuBtn.pressed.connect(mainMenu)
	InMain.visible = true
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = false
	
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
	
func mainMenu():
	unpause_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")
	
func _on_settings_btn_pressed():
	InMain.visible = false
	InSetting.visible = true
	InAudio.visible = false
	InVideo.visible = false

func _on_in_audio_setting_btn_pressed():
	InMain.visible = false
	InSetting.visible = false
	InAudio.visible = true
	InVideo.visible = false

func _on_in_video_setting_btn_pressed():
	InMain.visible = false
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = true

func _on_back_pause_btn_pressed():
	InMain.visible = true
	InSetting.visible = false
	InAudio.visible = false
	InVideo.visible = false

func _on_back_setting_btn_pressed():
	InMain.visible = false
	InSetting.visible = true
	InAudio.visible = false
	InVideo.visible = false

func _on_back_setting_btn_2_pressed():
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
	volume(0,value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)


