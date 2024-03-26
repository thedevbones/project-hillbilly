extends CharacterBody3D

var health = 5
var state = "patrol"
var hit_audio
var death_audio

var patrol_points = []  # Array of Vector3 points
var patrol_radius = 10.0  # Radius around the spawn position
var number_of_patrol_points = 5  # Number of patrol points to generate
var current_target = 0
var speed = 1.0
var arrived_distance = 1.0  # Distance to consider arrived at the target
var navigation_agent: NavigationAgent3D
var patrol_timer
var wait_time = 3.0  # Time to wait at each patrol point in seconds
var is_waiting = false  # Flag to check if the enemy is waiting

func spawn():
	# Initialize enemy settings
	navigation_agent = NavigationAgent3D.new()
	add_child(navigation_agent)
	generate_patrol_points()
	if patrol_points.size() > 0:
		navigation_agent.set_target_position(patrol_points[current_target])
	
	if patrol_timer:
		patrol_timer.wait_time = wait_time

func apply_damage(damage):
	health -= damage
	if hit_audio: hit_audio.play()
	if health <= 0:
		die()

func die():
	# Handle enemy death (e.g., play animation, remove from scene)
	if death_audio:
		death_audio.play()
	else: 
		queue_free()

func generate_patrol_points():
	var rng = RandomNumberGenerator.new()
	for i in range(number_of_patrol_points):
		var random_direction = Vector3(rng.randf_range(-1, 1), 0, rng.randf_range(-1, 1)).normalized()
		var random_distance = rng.randf_range(0, patrol_radius)
		var patrol_point = global_transform.origin + random_direction * random_distance
		patrol_points.append(patrol_point)

func _process(delta):
	match state:
		"patrol":
			patrol_behavior(delta)
		"combat":
			combat_behavior(delta)
		"search":
			search_behavior(delta)

func patrol_behavior(delta):
	if patrol_points.size() <= 0 or is_waiting: return
	
	var location = global_transform.origin
	var target_location = patrol_points[current_target]

	if location.distance_to(target_location) <= arrived_distance:
		# Arrived at the target, choose the next point
		is_waiting = true
		patrol_timer.start()

	# Get the next navigation point
	var next_point = navigation_agent.get_next_path_position()
	
	if next_point != Vector3.INF:
		# Move towards the next point
		var direction = (next_point - location).normalized()
		velocity = direction * speed  # Set the linear_velocity
		move_and_slide()  # Call move_and_slide without parameters


func combat_behavior(delta):
	# Implement combat logic
	pass

func search_behavior(delta):
	# Implement search logic
	pass
