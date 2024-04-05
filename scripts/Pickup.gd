extends Node3D

@onready var world = get_node("/root/World")
@onready var player = get_node("/root/World/Player")
var item

func _process(delta):
	rotation_degrees.y += 50 * delta

func _on_pickup_area_body_entered(body):
	if body == player: 
		$PickupSound.play()
		player.unlock_item(item)
		if world.current_state == world.GameState.GAME_START: world.switch_state(world.GameState.PREPARATION)
		hide()

func _on_pickup_sound_finished():
	queue_free()
