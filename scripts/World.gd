extends Node3D

enum GameState { GAME_START, IN_WAVE, PREPARATION, TIMEOUT, GAME_OVER }

var total_waves = 10
var current_state = GameState.GAME_START
var current_wave = 14
var enemies_alive = 0
var enemies_in_queue = 0
var boss_wave = 5
var wave_spawn_mult = 5
var demo_mode = false
var menu_scene = preload("res://scenes/MenuMain.tscn")

func _ready():
	var menu = menu_scene.instantiate()
	add_child(menu)
	switch_state(GameState.GAME_START)
	demo_mode = Graphics.demo_mode
	if demo_mode: adjust_demo_settings()

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
	current_wave += 1
	%UI.update_wave_count(current_wave)
	if current_wave % boss_wave == 0:
		$Spawner.spawn_boss(int(current_wave/boss_wave)) # change to current_wave/2 in sprint 3
		$BoundsTimer.start()
		return
	var enemies_to_spawn = [{"type": "weak", "count": current_wave * wave_spawn_mult}]
	$Spawner.spawn_wave(enemies_to_spawn)
	$BoundsTimer.start()
	print("Spawned " + str(enemies_alive) + " enemies")

func wave_completed():
	if %Player.health < 10: %Player.health = min(%Player.health + 3, 10)
	if current_wave == total_waves:
		victory()
	elif current_wave % boss_wave == 0 or current_wave == 2:
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
		wave_completed()
		enemies_alive = 0
	if amount < 0 and enemies_in_queue > 0:
		var enemies_to_spawn = [{"type": "weak", "count": 1}]
		$Spawner.spawn_wave(enemies_to_spawn)
		enemies_in_queue -= 1
		check_for_out_of_bounds()

func get_alive_enemies():
	return enemies_alive

func _on_bounds_timer_timeout():
	check_for_out_of_bounds()

func check_for_out_of_bounds():
	print("Checking for out-of-bounds")
	for child in $Spawner.get_children():
		if child is CharacterBody3D and is_out_of_bounds(child):
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
	$Spawner.spawn_upgrade_select()
	# switch_state(GameState.PREPARATION)

func adjust_demo_settings():
	boss_wave = 3
	wave_spawn_mult = 10
	# total_waves = 4


func _on_ambience_finished():
	$ambience.play()

func _on_storm_finished():
	$storm.play()
