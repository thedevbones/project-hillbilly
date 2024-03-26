extends ColorRect


@onready var ResumeBtn: Button = find_child("ResumeBtn")
@onready var QuitBtn: Button = find_child("QuitBtn")
@onready var MenuBtn: Button = find_child("MenuBtn")
@onready var InPaused = $PauseMain
@onready var InSetting = $PauseSetting
@onready var InAudio = $PauseAudio
@onready var InVideo = $PausedVideo

func _ready() -> void:
	ResumeBtn.pressed.connect(unpaused)
	QuitBtn.pressed.connect(get_tree().quit)
	MenuBtn.pressed.connect(mainMenu)

func unpaused():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	
func paused():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func mainMenu():
	unpaused()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")
