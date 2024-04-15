extends "res://scripts/EnemyBase.gd"

##@onready var ani_tree = $AnimationTree
@onready var animation_player 
const LERP = 1.5
var anim_name = "walk"

func _ready():
	spawn()
	hit_audio = $BulletHit
	death_audio = $Death
	attack_audio = $Swing
	hit_timer = $HitTimer
	damage_type = "axe"
	#patrol_timer = $PatrolTimer
	animation_player = $AnimationPlayer
	animation_player.play("walk")
	$Armature/Skeleton3D.physical_bones_start_simulation()
	$Armature/Skeleton3D.physical_bones_stop_simulation()

func _on_death_finished():
	queue_free()
	
func attack_player():
	call_deferred("_attack_player")

func _attack_player():
	anim_name = "Attack_animation"
	animation_player.play(anim_name)
	player.apply_damage(damage, damage_type)

func movement():
	call_deferred("_movement")
	
func _movement():
	if anim_name == "Attack_animation":
		anim_name = "walk"
		animation_player.play(anim_name, 1.0)
	
#func _on_patrol_timer_timeout():
	#is_waiting = false
	#current_target = (current_target + 1) % patrol_points.size()
	#navigation_agent.set_target_position(patrol_points[current_target])
