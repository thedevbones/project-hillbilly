extends CanvasLayer

func _on_main_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/Tutorials/MainControls.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")
