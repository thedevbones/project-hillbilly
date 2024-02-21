extends CharacterBody3D

const NORMAL_FOV = 70.0
const SPRINT_FOV = 90.0
const NORMAL_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_STAMINA = 10
const SPRINT_MULTIPLIER = 1.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.2
var speed = NORMAL_SPEED
var stamina = MAX_STAMINA
var is_sprinting = false
var can_sprint = true


func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Sprinting logic
	if Input.is_action_pressed("sprint") and stamina > 0 and can_sprint:
		is_sprinting = true
	else:
		is_sprinting = false

	if is_sprinting:
		speed = NORMAL_SPEED * SPRINT_MULTIPLIER
		stamina -= delta  # Stamina depletes continuously while sprinting
		$Camera3D.fov = lerp($Camera3D.fov, SPRINT_FOV, 0.1)
		if stamina <= 0.0:
			stamina = 0.0  # Clamp stamina to zero
			is_sprinting = false
			can_sprint = false

	# Stamina regeneration logic
	if not is_sprinting:
		speed = NORMAL_SPEED
		stamina += delta / 2
		stamina = min(stamina, MAX_STAMINA)  # Clamp stamina to its maximum value
		$Camera3D.fov = lerp($Camera3D.fov, NORMAL_FOV, 0.1)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("walk_left", "walk_right", "walk_foward", "walk_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
