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


func combat_behavior(_delta):
	if player == null: return 

	var player_position = player.global_transform.origin
	var location = global_transform.origin
	var animation = "walk"
	
	if location.distance_to(player_position) < 20:
		speed = default_speed * 2
		navigation_agent.set_target_position(player_position)
		var next_point = navigation_agent.get_next_path_position()
		var direction = (next_point - location).normalized()
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = target_angle
		if location.distance_to(player_position) <= attack_distance:
			if hit_timer.get_time_left() == 0 and not player.dying and health > 0:
				attack_player()
				hit_timer.start()
				attack_audio.play()
				speed = 0
			elif next_point != Vector3.INF and hit_timer.get_time_left() == 0:
				velocity = direction * speed
				move_and_slide()
				movement()
	else:
		speed = default_speed
		if patrol_points.size() <= 0 or is_waiting: return
		var target_location = patrol_points[current_target]
		if location.distance_to(target_location) <= arrived_distance:
			is_waiting = true
			patrol_timer.start()
#
		var next_point = navigation_agent.get_next_path_position()
	
		if next_point != Vector3.INF:
			var direction = (next_point - location).normalized()
			velocity = direction * speed
			move_and_slide()
		
		
		current_target = (current_target + 1) % patrol_points.size()
		navigation_agent.set_target_position(patrol_points[current_target])


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


func _on_bullet_hit_finished():
	pass # Replace with function body.
