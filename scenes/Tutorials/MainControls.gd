extends CanvasLayer


func _on_attack_controls_pressed():
	get_tree().change_scene_to_file("res://scenes/Tutorials/AttackControls.tscn")


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/MenuMain.tscn")
