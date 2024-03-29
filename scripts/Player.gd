extends CharacterBody3D

enum Weapons { UNARMED, PIPE, KNIFE, PISTOL, SHOTGUN }

const NORMAL_FOV = 70.0
const SPRINT_FOV = 90.0
const ADS_FOV = 60.0
const NORMAL_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_STAMINA = 10
const SPRINT_MULTIPLIER = 1.5
const CROUCH_MULTIPLIER = 0.75

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
var push_force = 8.0

# Weapon variables
var weapons = {}
var current_weapon_index = 0
var can_switch = true
var inventory = {
	Weapons.UNARMED: {"is_unlocked": true, "ammo": 0},
	Weapons.PIPE: {"is_unlocked": false, "ammo": 0},
	Weapons.KNIFE: {"is_unlocked": false, "ammo": 0},
	Weapons.PISTOL: {"is_unlocked": false, "ammo": 0},
	Weapons.SHOTGUN: {"is_unlocked": false, "ammo": 0},
}

func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$StepTimer.wait_time = 0.6 
	$StepTimer.start()
	# Initialize weapons 
	weapons[Weapons.UNARMED] = null
	weapons[Weapons.PIPE] = $MainCamera/Pipe
	weapons[Weapons.KNIFE] = $MainCamera/Knife
	weapons[Weapons.PISTOL] = $MainCamera/Pistol
	weapons[Weapons.SHOTGUN] = $MainCamera/Shotgun

func _input(event):	
	# Handle weapon inputs
	if event.is_action_pressed("fire"):
		attack()
	if event.is_action_pressed("reload"):
		reload()
	if event.is_action_pressed("aim"):
		aim()
	# Handle number key presses for direct weapon selection
	for i in range(weapons.size()):
		if event.is_action_pressed("ui_select_" + str(i + 1)):
			switch_weapon_by_index(i)
			break
	# Handle mouse wheel for switching weapons
	if event.is_action_pressed("scroll_up"):
		var prev_index = current_weapon_index - 1
		prev_index = wrap_index(prev_index)
		switch_weapon_by_index(prev_index)
	elif event.is_action_pressed("scroll_down"):
		var next_index = current_weapon_index + 1
		next_index = wrap_index(next_index)
		switch_weapon_by_index(next_index)
	# Handle mouse input
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		$MainCamera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		# Clamp the camera's vertical rotation
		$MainCamera.rotation.x = clamp($MainCamera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# Gravity logic
	if not is_on_floor():
		velocity.y -= gravity * delta
		falling = true
	if falling and is_on_floor():
		$StepAudio.play()
		falling = false
	# Handle jump
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
	# Sprinting/Crouching logic
	if is_sprinting:
		$StepTimer.wait_time = 0.3
		$StepAudio.set_max_db(-4)
		speed = NORMAL_SPEED * SPRINT_MULTIPLIER
		stamina -= delta
		$MainCamera.fov = lerp($MainCamera.fov, SPRINT_FOV, 0.1)
		if stamina <= 0.0:
			stamina = 0.0  # Clamp stamina to zero
			is_sprinting = false
			can_sprint = false
	elif is_crouching:
		$StepTimer.wait_time = 1.2 
		$StepAudio.set_max_db(-10)
		$MainCamera.global_transform.origin.y = lerp($MainCamera.global_transform.origin.y, global_transform.origin.y - 0.5, delta * 10)
		speed = NORMAL_SPEED * CROUCH_MULTIPLIER
		can_sprint = false
		stamina += delta / 2
		stamina = min(stamina, MAX_STAMINA) 
	else:
		$StepTimer.wait_time = 0.6 
		$StepAudio.set_max_db(-7)
		$MainCamera.global_transform.origin.y = lerp($MainCamera.global_transform.origin.y, global_transform.origin.y, delta * 10)
		$MainCamera.fov = lerp($MainCamera.fov, NORMAL_FOV, 0.1)
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
	move_and_slide()
	# Getting slide collision
	for i in get_slide_collision_count():
		var c_object = get_slide_collision(i)
		if c_object.get_collider() is RigidBody3D and is_moving:
			c_object.get_collider().apply_central_impulse(-c_object.get_normal() * push_force)
			is_sprinting = false
			can_sprint = false
			break

func _on_step_timer_timeout():
	if is_moving and is_on_floor():
		$StepAudio.pitch_scale = randf_range(0.8, 1.2)
		$StepAudio.play()

func attack():
	var weapon = get_current_weapon()
	if not weapon:
		return
	if weapon.ranged:
		if weapon.ammo > 0: weapon.shoot()
		else: $NoAmmo.play()
	else:
		weapon.swing()

func reload():
	var weapon = get_current_weapon()
	if weapon and weapon.ranged:
		weapon.reload()

func aim():
	var weapon = get_current_weapon()
	if weapon and weapon.ranged:
		weapon.aim()

func switch_weapon_by_index(index):
	if not can_switch:
		return
	if index in weapons:
		current_weapon_index = index
		update_weapon_visibility()

func update_weapon_visibility():
	for i in weapons.keys():
		var weapon = weapons[i]
		if weapon: weapon.visible = i == current_weapon_index
	update_hitscan()

func update_hitscan():
	var weapon = get_current_weapon()
	if weapon:
		$MainCamera/HitScan.set_scale(weapons[current_weapon_index].range)
		print(str(get_current_weapon()) + str($MainCamera/HitScan.get_scale()))
	
func get_current_weapon():
	return weapons[current_weapon_index]

func wrap_index(index):
	if index < 0: return weapons.size() - 1
	elif index >= weapons.size(): return 0
	else: return index
