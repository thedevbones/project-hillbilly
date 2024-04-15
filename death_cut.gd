extends Node2D

func _on_button_pressed():
	get_tree().reload_current_scene()

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_animation_player_animation_started(Death):
	$AnimationPlayer.play()
