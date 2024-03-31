extends Node3D

enum GameState { GAME_START, IN_WAVE, PREPARATION, GAME_OVER }
const TOTAL_WAVES = 10
var current_state = GameState.GAME_START
var current_wave = 0

func _ready():
	# Initialization logic here
	switch_state(GameState.PREPARATION)

func _on_preparation_timeout():
	switch_state(GameState.IN_WAVE)

func _on_wave_timeout():
	# Optional: Force end wave if there's a time limit
	on_wave_completed()

func switch_state(new_state):
	current_state = new_state
	print(str(current_state))
	match current_state:
		GameState.GAME_START:
			# Initial game setup or intro here
			pass
		GameState.PREPARATION:
			# Perform cleanup, setup for next wave
			$PrepTimer.start()
		GameState.IN_WAVE:
			start_wave()
		GameState.GAME_OVER:
			# Handle game over logic, display UI, etc.
			pass

func start_wave():
	current_wave += 1
	var enemies_to_spawn = [{"type": "weak", "count": current_wave * 3}]
	$Spawner.spawn_wave(enemies_to_spawn)

func on_wave_completed():
	if current_wave == TOTAL_WAVES:
		victory()
	else:
		switch_state(GameState.PREPARATION)

# Implement additional logic for monitoring and transitioning game states, like detecting when all enemies are dead.

func victory():
	pass

func _on_prep_timer_timeout():
	print("Timeout")
	switch_state(GameState.IN_WAVE)
