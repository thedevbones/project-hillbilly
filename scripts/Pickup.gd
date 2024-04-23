extends Node3D

@onready var world = get_node("/root/World")
@onready var player = get_node("/root/World/Player")
@onready var gui = get_node("/root/World/UI")
var item
var enabled = false

func _process(delta):
	rotation_degrees.y += 50 * delta

func _on_pickup_area_body_entered(body):
	if body == player and gui.pickups_enabled: 
		$PickupSound.play()
		player.unlock_item(item)
		hide()

func _on_pickup_sound_finished():
	queue_free()
