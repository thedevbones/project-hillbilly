extends Control


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_settings_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuSettings.tscn")

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_tutorial_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuTutorial.tscn")
