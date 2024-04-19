extends Node3D

var enemy_weak = preload("res://scenes/EnemyWeak.tscn")
var enemy_weak_alt = preload("res://scenes/EnemyWeak2.tscn")
# var enemy_strong = preload("res://path/to/EnemyStrong.tscn")
var boss = preload("res://scenes/Boss.tscn")
@onready var world = get_parent()

var spawn_points = []

func _ready():
	spawn_points = get_children()

func spawn_enemy(enemy_type, spawn_point):
	var enemy_instance
	#match enemy_type:
	#	"weak": enemy_scene1 = enemy_weak
	#	"weak": enemy_scene2 = enemy_weak_alt
		# "strong": enemy_scene = enemy_strong
	var random_number = randi_range(0, 1)
	if random_number == 1:
		enemy_instance = enemy_weak.instantiate()
	else: 
		enemy_instance = enemy_weak_alt.instantiate()
	add_child(enemy_instance) 
	enemy_instance.global_transform.origin = spawn_point.global_transform.origin

func spawn_wave(enemies_to_spawn):
	var max_enemies = Graphics.get_max_enemies()
	for enemy_info in enemies_to_spawn:
		for i in range(enemy_info.count):
			if world.enemies_alive >= max_enemies:
				print("Reached max of ", max_enemies, " enemies")
				world.enemies_in_queue = enemy_info.count - world.enemies_alive
				return
			var spawn_point = choose_spawn_point()
			spawn_enemy(enemy_info.type, spawn_point)

func spawn_boss(boss_level):
	var spawn_point = choose_spawn_point()
	var boss_instance = boss.instantiate()
	add_child(boss_instance)
	boss_instance.set_level(boss_level)
	boss_instance.global_transform.origin = spawn_point.global_transform.origin

func spawn_particle(scene_name, spawn_position):
	var scene_path = "res://scenes/" + scene_name
	var scene = load(scene_path)
	if scene:
		var instance = scene.instantiate()
		instance.global_transform.origin = spawn_position
		add_child(instance)
		
		var timer = Timer.new()
		timer.wait_time = 0.3
		timer.one_shot = true
		add_child(timer)
		timer.timeout.connect(remove_instance.bind(instance))
		timer.start()

func remove_instance(instance):
	remove_child(instance)
	instance.queue_free()

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
		var spawn_position = %Player.global_transform.origin + forward_direction * 5.0
		instance.global_transform.origin = spawn_position
		instance.look_at(spawn_position - forward_direction, Vector3.UP)
		add_child(instance)

func spawn_ranged_upgrades():
	var scene = load("res://scenes/PickupRangedUpgrade.tscn")
	if scene:
		var instance = scene.instantiate()
		var forward_direction = %Player.global_transform.basis.z.normalized() * -1
		var spawn_position = %Player.global_transform.origin + forward_direction * 5.0
		instance.global_transform.origin = spawn_position
		add_child(instance)

func spawn_melee_upgrades():
	var scene = load("res://scenes/PickupMeleeUpgrade.tscn")
	if scene:
		var instance = scene.instantiate()
		var forward_direction = %Player.global_transform.basis.z.normalized() * -1
		var spawn_position = %Player.global_transform.origin + forward_direction * 2.0
		instance.global_transform.origin = spawn_position
		instance.look_at(spawn_position - forward_direction, Vector3.UP)
		add_child(instance)

func choose_spawn_point():
	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var max_offset = 5
	spawn_point.global_transform.origin.x += randi_range(-max_offset, max_offset)
	spawn_point.global_transform.origin.z += randi_range(-max_offset, max_offset)
	return spawn_point
