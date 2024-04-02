extends Node3D

var enemy_weak = preload("res://scenes/EnemyWeak.tscn")
# var enemy_strong = preload("res://path/to/EnemyStrong.tscn")

var spawn_points = []

func _ready():
	spawn_points = get_children()

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
		for i in range(enemy_info.count):
			var spawn_point = choose_spawn_point()
			spawn_enemy(enemy_info.type, spawn_point)

func spawn_drop(scene_name, spawn_position):
	var scene_path = "res://scenes/" + scene_name
	var scene = load(scene_path)
	if scene:
		var instance = scene.instantiate()
		instance.global_transform.origin = spawn_position
		add_child(instance)

func spawn_upgrade_select():
	var scene = load("res://scenes/PickupUpgrade.tscn")
	if scene:
		var instance = scene.instantiate()
		var forward_direction = %Player.global_transform.basis.z.normalized() * -1
		var spawn_position = %Player.global_transform.origin + forward_direction * 3.0
		instance.global_transform.origin = spawn_position
		add_child(instance)

func spawn_ranged_upgrades():
	var scene = load("res://scenes/PickupRangedUpgrade.tscn")
	if scene:
		var instance = scene.instantiate()
		var forward_direction = %Player.global_transform.basis.z.normalized() * -1
		var spawn_position = %Player.global_transform.origin + forward_direction * 3.0
		instance.global_transform.origin = spawn_position
		add_child(instance)

func spawn_melee_upgrades():
	pass

func choose_spawn_point():
	return spawn_points[randi() % spawn_points.size()]
