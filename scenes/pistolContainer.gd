extends Node3D

@export var isLocked := false
@export var needsKey := false
@export var neededkey : StaticBody3D

var isOpen = false;
var canInteract = true;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func action_use():
	#if !isLocked: 
		#insert noise to show it is locked
	#	if needsKey:
	#		print("Needs a key")
	#		if !is_instance_vaild(neededkey):
	#			print("Door Unlocked")
	#			isLocked = false
	#			open_contain()
	if !isOpen and canInteract: 
		open_contain()

func open_contain():
	canInteract = false
	$AnimationPlayer.play("open")
	$ContainAnimationPlayer.play("open")
	isOpen = true
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
