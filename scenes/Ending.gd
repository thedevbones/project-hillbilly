extends Node2D
@onready var videoPlayer : VideoStreamPlayer = $VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_video_stream_player_finished():
	get_tree().quit()
