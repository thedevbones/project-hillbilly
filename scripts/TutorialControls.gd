extends CanvasLayer

class_name ui


func _on_main_controls_toggle_pressed():
	pass # Replace with function body.

func _on_attack_controls_toggle_pressed():
	pass # Replace with function body.

func _on_back_to_world_pressed():
	print("back to world Pressed")
	get_tree().change_scene_to_file("res://world.tscn")

