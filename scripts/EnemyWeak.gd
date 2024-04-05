extends "res://scripts/EnemyBase.gd"

@onready var ani_tree = $AnimationTree

const LERP = 1.5

func _ready():
	spawn()
	hit_audio = $BulletHit
	death_audio = $Death
	#patrol_timer = $PatrolTimer
	ani_tree.set("parameters/BlendSpace1D/blend_position",speed)

func _on_death_finished():
	queue_free()
	

#func _on_patrol_timer_timeout():
	#is_waiting = false
	#current_target = (current_target + 1) % patrol_points.size()
	#navigation_agent.set_target_position(patrol_points[current_target])
