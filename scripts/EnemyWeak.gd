extends "res://scripts/EnemyBase.gd"

##@onready var ani_tree = $AnimationTree
@onready var animation_player 
const LERP = 1.5
var anim_name = "walk"
var knockback_force = 20


func _ready():
	spawn()
	generate_patrol_points()
	hit_audio = $BulletHit
	death_audio = $Death
	attack_audio = $Swing
	hit_timer = $HitTimer
	damage_type = "axe"
	patrol_timer = $PatrolTimer
	var anim : Animation= $AnimationPlayer.get_animation(anim_name)
	anim.loop_mode =(Animation.LOOP_LINEAR)
	animation_player = $AnimationPlayer
	animation_player.play("walk")
	$Armature/Skeleton3D.physical_bones_start_simulation()
	$Armature/Skeleton3D.physical_bones_stop_simulation()


func apply_damage(damage):
	health -= damage
	hit_audio.play()
	anim_name = "idle2"
	animation_player.play(anim_name)
	if health <= 0: die()
	# Calculate knockback direction
	var knockback_direction = -(player.global_transform.origin - global_transform.origin).normalized()
	# Apply knockback force to enemy
	knockback(knockback_direction)
	anim_name = "idle2"
	animation_player.play(anim_name)
	movement()
	


func combat_behavior(_delta):
	if player == null: return 

	var player_position = player.global_transform.origin
	var location = global_transform.origin
	var direction
	
	if location.distance_to(player_position) < 18:
		speed = default_speed + 2
		navigation_agent.set_target_position(player_position)
		
		var next_point = navigation_agent.get_next_path_position()
		direction = (next_point - location).normalized()
		var target_angle = atan2(direction.x, direction.z)
		var animation = "walk"
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
		speed = default_speed / 1.5
		if patrol_points.size() > 0:
			var target_location = patrol_points[current_target]
			navigation_agent.set_target_position(target_location)
	
			var next_point = navigation_agent.get_next_path_position()
			if next_point != Vector3.INF:
				direction = (next_point - location).normalized()
				var target_angle = atan2(direction.x, direction.z)
				anim_name = "walk"
				rotation.y = target_angle
			
			if location.distance_to(target_location) < 1:
				current_target = (current_target + 1) % patrol_points.size()
				
			if next_point != Vector3.INF and hit_timer.get_time_left() == 0:
				velocity = direction * speed
				move_and_slide()
				movement()
				
	
	if location.distance_to(player_position) <= attack_distance:
		if hit_timer.get_time_left() == 0 and not player.dying and health > 0:
			attack_player()
			hit_timer.start()
			attack_audio.play()
			speed = 0
	


func _on_death_finished():
	queue_free()


func knockback(direction: Vector3):
	velocity = direction * knockback_force
	move_and_slide()

	
func attack_player():
	call_deferred("_attack_player")


func _attack_player():
	anim_name = "Attack_animation"
	animation_player.play(anim_name)
	player.apply_damage(damage, damage_type)


func movement():
	call_deferred("_movement")

	
func _movement():
	if anim_name != "walk":
		anim_name = "walk"
		animation_player.play(anim_name, 1.0)


func _on_bullet_hit_finished():
	pass # Replace with function body.
