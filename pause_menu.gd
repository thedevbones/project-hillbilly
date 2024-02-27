extends ColorRect


@onready var ResumeBtn: Button = find_child("ResumeBtn")
@onready var QuitBtn: Button = find_child("QuitBtn")
@onready var MenuBtn: Button = find_child("MenuBtn")

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
	get_tree().change_scene_to_file("res://main_menu.tscn")
