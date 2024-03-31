extends Node3D

@onready var world = get_node("/root/World")
var item

func _process(delta):
	rotation_degrees.y += 50 * delta

func _on_pickup_area_body_entered(body):
	var player = %Player
	if body == player: 
		$PickupSound.play()
		player.unlock_item(item)
		if world.current_wave == 0: world.switch_state(world.GameState.IN_WAVE)
		hide()

func _on_pickup_sound_finished():
	queue_free()
