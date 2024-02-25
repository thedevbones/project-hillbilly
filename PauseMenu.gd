extends Control

func _on_menu_btn_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_quit_btn_pressed():
	get_tree().quit()
