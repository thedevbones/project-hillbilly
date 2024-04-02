extends Node3D

enum GameState { GAME_START, IN_WAVE, PREPARATION, TIMEOUT, GAME_OVER }
const TOTAL_WAVES = 10
var current_state = GameState.GAME_START
var current_wave = 0
var enemies_alive = 0

func _ready():
	switch_state(GameState.GAME_START)
	prompt_upgrade()

func switch_state(new_state):
	current_state = new_state
	match current_state:
		GameState.GAME_START:
			pass
		GameState.PREPARATION:
			$PrepTimer.start()
		GameState.IN_WAVE:
			start_wave()
		GameState.TIMEOUT:
			prompt_upgrade()
		GameState.GAME_OVER:
			pass

func start_wave():
	%UI.update_wave_count(current_wave)
	current_wave += 1
	var enemies_to_spawn = [{"type": "weak", "count": current_wave * 5}]
	$Spawner.spawn_wave(enemies_to_spawn)
	$BoundsTimer.start()
	print("Spawned " + str(enemies_alive) + " enemies")

func on_wave_completed():
	if current_wave == TOTAL_WAVES:
		victory()
	elif current_wave % 5 == 0:
		switch_state(GameState.TIMEOUT)
	else:
		switch_state(GameState.PREPARATION)

func victory():
	pass

func _on_prep_timer_timeout():
	switch_state(GameState.IN_WAVE)

func add_alive_enemies(amount):
	enemies_alive += amount
	if enemies_alive <= 0:
		switch_state(GameState.PREPARATION)

func get_alive_enemies():
	return enemies_alive

func _on_bounds_timer_timeout():
	print("Checking for out-of-bounds")
	for child in $Spawner.get_children():
		if not child is Marker3D and is_out_of_bounds(child):
			respawn(child)

func is_out_of_bounds(child):
	var pos = child.global_transform.origin
	if not $GameBounds.get_overlapping_bodies().has(child): 
		print("Enemy is out of bounds! At " + str(int(pos.x)) + "," + str(int(pos.y)) + "," + str(int(pos.z)))
		return true
	return false

func respawn(enemy):
	var spawn_point = $Spawner.choose_spawn_point()
	enemy.global_transform.origin = spawn_point.global_transform.origin
	$BoundsTimer.start()

func prompt_upgrade():
	%UI.update_upgrade_prompt()
