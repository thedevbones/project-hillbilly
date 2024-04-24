extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_main_menu_pressed():
	Graphics.in_game = false
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")

func _on_quit_pressed():
	Graphics.in_game = false
	get_tree().quit()

func _on_animation_player_animation_started(Death):
	$AnimationPlayer.play()
