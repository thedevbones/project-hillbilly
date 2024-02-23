extends CharacterBody3D

const NORMAL_FOV = 70.0
const SPRINT_FOV = 90.0
const NORMAL_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_STAMINA = 10
const SPRINT_MULTIPLIER = 1.5
const CROUCH_MULTIPLIER = 0.75

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.2
var speed = NORMAL_SPEED
var stamina = MAX_STAMINA
var is_sprinting = false
var is_crouching = false
var is_moving = false
var can_sprint = true
var falling = false

# Collision variables
var push_force = 5.0

func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$StepTimer.wait_time = 0.6 
	$StepTimer.start() 

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		$Camera3D.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		# Clamp the camera's vertical rotation
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		falling = true
	
	if falling and is_on_floor():
		$StepAudio.play()
		falling = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching and stamina > 0:
		velocity.y = JUMP_VELOCITY
		stamina -= 1

	# Input manager
	if not can_sprint and not Input.is_action_pressed("sprint") and stamina >= 1:
		can_sprint = true

	if Input.is_action_pressed("sprint") and can_sprint and get_velocity().length() > 0:
		is_sprinting = true
	else:
		is_sprinting = false

	if Input.is_action_pressed("crouch"):
		is_crouching = true
	else:
		is_crouching = false

	# Sprinting logic
	if is_sprinting:
		$StepTimer.wait_time = 0.3
		$StepAudio.set_max_db(-4)
		speed = NORMAL_SPEED * SPRINT_MULTIPLIER
		stamina -= delta  # Stamina depletes continuously while sprinting
		$Camera3D.fov = lerp($Camera3D.fov, SPRINT_FOV, 0.1)
		if stamina <= 0.0:
			stamina = 0.0  # Clamp stamina to zero
			is_sprinting = false
			can_sprint = false
			
	elif is_crouching:
		$StepTimer.wait_time = 1.2 
		$StepAudio.set_max_db(-10)
		$Camera3D.global_transform.origin.y = lerp($Camera3D.global_transform.origin.y, global_transform.origin.y - 0.5, delta * 10)
		speed = NORMAL_SPEED * CROUCH_MULTIPLIER
		can_sprint = false
		stamina += delta / 2
		stamina = min(stamina, MAX_STAMINA) 
	else:
		$StepTimer.wait_time = 0.6 
		$StepAudio.set_max_db(-7)
		$Camera3D.global_transform.origin.y = lerp($Camera3D.global_transform.origin.y, global_transform.origin.y, delta * 10)
		$Camera3D.fov = lerp($Camera3D.fov, NORMAL_FOV, 0.1)
		speed = NORMAL_SPEED
		stamina += delta / 2
		stamina = min(stamina, MAX_STAMINA)  # Clamp stamina to its maximum value

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_foward", "walk_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		is_moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		is_moving = false
	
	# print("sprinting: " + str(is_sprinting) + " crouching: " + str(is_crouching) + " can sprint: " + str(can_sprint) + " stamina: " + str(stamina) + " speed: " + str(speed))
	move_and_slide()
	
	# getting slide collision
	for i in get_slide_collision_count():
		var c_object = get_slide_collision(i)
		if c_object.get_collider() is RigidBody3D and is_moving:
			c_object.get_collider().apply_central_impulse(-c_object.get_normal() * push_force)
			break
		
				
func _on_step_timer_timeout():
	if (get_velocity().length() > 0 and is_on_floor()) or is_moving:
		print("from timeout")
		$StepAudio.pitch_scale = randf_range(0.8, 1.2)
		$StepAudio.play()
