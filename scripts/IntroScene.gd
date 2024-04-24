extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):	
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/World.tscn")

func _on_animation_player_animation_finished(anim_name):
	var tween1 = get_tree().create_tween()
	tween1.tween_property($BlackScreen, "modulate", Color("ffffff", 1.5), 2)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/World.tscn")
	
	
	
