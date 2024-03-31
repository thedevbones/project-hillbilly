extends Node3D

# Assume enemy scenes are preloaded or dynamically loaded
var enemy_weak = preload("res://scenes/EnemyWeak.tscn")
# var enemy_strong = preload("res://path/to/EnemyStrong.tscn")

# A list of spawn points, manually assigned or dynamically found
var spawn_points = []

func _ready():
	# Optionally, find all spawn points automatically if they're named consistently
	spawn_points = get_children() # Assuming all children are spawn points

func spawn_enemy(enemy_type, spawn_point):
	var enemy_scene
	match enemy_type:
		"weak": enemy_scene = enemy_weak
		# "strong": enemy_scene = enemy_strong
	
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance) 
	enemy_instance.global_transform.origin = spawn_point.global_transform.origin

func spawn_wave(enemies_to_spawn):
	for enemy_info in enemies_to_spawn:
		var spawn_point = choose_spawn_point()
		spawn_enemy(enemy_info.type, spawn_point)

func choose_spawn_point():
	# Simple random selection; can be expanded with more logic
	return spawn_points[randi() % spawn_points.size()]
