extends StaticBody3D

@export var isLocked := false
@export var needsKey := false
@export var neededkey : StaticBody3D

var isOpen = false;
var canInteract = true;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func action_used():
	#if !isLocked: 
		#insert noise to show it is locked
	#	if needsKey:
	#		print("Needs a key")
	#		if !is_instance_vaild(neededkey):
	#			print("Door Unlocked")
	#			isLocked = false
	#			open_contain()
	if isOpen == false and canInteract == true: 
		open_contain()

func open_contain():
	canInteract = false
	#$AnimationPlayer.play("open")
	
	$ContainAnimationPlayer.play("open")
	isOpen = true
	
