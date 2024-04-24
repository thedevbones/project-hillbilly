extends Camera3D

@onready var main_camera = $"../../../Player/Neck/Head/MainCamera"
# Called when the node enters the scene tree for the first time.
func _ready():
	projection = main_camera.projection
	size = main_camera.size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_transform = main_camera.global_transform
