extends CanvasLayer

func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_tutorial_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuTutorial.tscn")

@onready var main = $"Main Menu"
@onready var settings = $SettingsControl
@onready var audio = $Audio
@onready var video = $Video

func _ready():
	main.visible = true
	settings.visible = false
	audio.visible = false
	video.visible = false

func _on_main_menu_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")
	
func _on_back_btn_pressed():
	settings.visible = true
	audio.visible = false

func _on_audio_setting_btn_pressed():
	audio.visible = true
	settings.visible = false
	
func _on_video_setting_btn_pressed():
	video.visible = true
	settings.visible = false
	
func _on_master_value_changed(value):
	volume(0,value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)

func _on_music_value_changed(value):
	volume(1,value)

func _on_sound_fx_value_changed(value):
	volume(2,value)

func _on_check_box_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_btn_2_pressed():
	video.visible = false
	settings.visible = true
