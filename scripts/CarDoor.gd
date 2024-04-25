extends StaticBody3D

@export var isLocked := false
@export var needsKey := false
@export var neededkey : StaticBody3D

var isOpen = false;
var canInteract = true;

func _ready() -> void:
	pass
	
func action_used():
	if isLocked: 
		#insert noise to show it is locked
		if needsKey:
			print("Needs gas")
			if !is_instance_valid(neededkey):
				print("Door Unlocked")
				isLocked = false
				open_contain()
	elif !isOpen and canInteract : 
		open_contain()

func open_contain():
	canInteract = false
	isOpen = true
	$Door.play()
	%Player.dying = true


func _on_door_finished():
	%UI.fade_element(%UI.black_screen, "modulate", Color("ffffff", 1), 1.5)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/Ending.tscn")
