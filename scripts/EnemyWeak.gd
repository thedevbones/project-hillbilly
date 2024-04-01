extends "res://scripts/EnemyBase.gd"

func _ready():
	spawn()
	hit_audio = $BulletHit
	death_audio = $Death
	#patrol_timer = $PatrolTimer

func _on_death_finished():
	world.add_alive_enemies(-1)
	drop_loot()
	queue_free()

#func _on_patrol_timer_timeout():
	#is_waiting = false
	#current_target = (current_target + 1) % patrol_points.size()
	#navigation_agent.set_target_position(patrol_points[current_target])
