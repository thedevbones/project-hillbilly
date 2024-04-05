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
			print("Needs a key")
			if !is_instance_valid(neededkey):
				print("Door Unlocked")
				isLocked = false
				open_contain()
	elif !isOpen and canInteract : 
		open_contain()

func open_contain():
	canInteract = false
	var animPlayer = $/root/World/padlock1/AnimationPlayer
	animPlayer.play("open")
	animPlayer = $/root/World/PistolContainer2/ContainAnimationPlayer
	animPlayer.play("open")
	isOpen = true
	
