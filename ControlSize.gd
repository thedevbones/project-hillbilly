extends Control


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_quit_btn_pressed():
	get_tree().quit()
