extends CharacterBody3D

@onready var raycast : RayCast3D = $/root/World/Player/MainCamera/HitScan

enum Weapons { UNARMED = 0, PIPE = 1, KNIFE = 2, PISTOL = 3, SHOTGUN = 4}
enum Items { FLASHLIGHT = 10, KEY = 11}

const NORMAL_FOV = 70.0
const SPRINT_FOV = 90.0
const ADS_FOV = 60.0
const NORMAL_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_STAMINA = 10
const SPRINT_MULTIPLIER = 1.5
const CROUCH_MULTIPLIER = 0.75
const BOB_FREQUENCY = 2.0
const BOB_AMPLITUDE = 0.08

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity = 0.2
var bob_time = 0.0
var speed = NORMAL_SPEED
var stamina = MAX_STAMINA
var max_health = 10
var health = max_health
var is_sprinting = false
var is_crouching = false
var is_moving = false
var can_sprint = true
var falling = false
var dying = false

# Collision variables
var push_force = 8.0

# Weapon variables
var weapons = {}
var items = {}
var current_weapon_index = 0
var can_switch = true
var weapon_to_upgrade
var inventory = {
	Weapons.UNARMED: {"is_unlocked": true, "total_ammo": 0},
	Weapons.PIPE: {"is_unlocked": false, "total_ammo": 0},
	Weapons.KNIFE: {"is_unlocked": false, "total_ammo": 0},
	Weapons.PISTOL: {"is_unlocked": false, "total_ammo": 0},
	Weapons.SHOTGUN: {"is_unlocked": false, "total_ammo": 0},
	Items.FLASHLIGHT: {"is_unlocked": false, "total_ammo": 0},
}

var hurt_sounds = [
	preload("res://audio/SFX/Damage/Player_pain_grunt2.mp3"),
	preload("res://audio/SFX/Damage/Player_pain_grunt.mp3"),
]
var impact_sounds = {
	0: preload("res://audio/SFX/Damage/Axe_impact.mp3"),
	1: preload("res://audio/SFX/Damage/Blunt_hit.mp3"),
	2: preload("res://audio/SFX/Damage/Blunt_impact_on_body.mp3"),
	3: preload("res://audio/SFX/Damage/bullut_hit_flesh.wav"),
	4: preload("res://audio/SFX/Damage/Shovel_impact.mp3"),
	5: preload("res://audio/SFX/Damage/skull_crack_melee_impact.mp3"),
	6: preload("res://audio/SFX/Damage/Stabbing_impact.mp3"),
}

func _ready():
	# Capture the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$StepTimer.wait_time = 0.6 
	$StepTimer.start()
	# Initialize weapons 
	weapons[Weapons.UNARMED] = null
	weapons[Weapons.PIPE] = $Head/MainCamera/Pipe
	weapons[Weapons.KNIFE] = $Head/MainCamera/Knife
	weapons[Weapons.PISTOL] = $Head/MainCamera/Pistol
	weapons[Weapons.SHOTGUN] = $Head/MainCamera/Shotgun
	items[Items.FLASHLIGHT] = $Head/MainCamera/Flashlight
	%UI.update_ammo_count()
	if Graphics.demo_mode:
		add_ammo(Weapons.SHOTGUN, 24)
		add_ammo(Weapons.PISTOL, 32)
		health = 20
		max_health = 20
		%UI.health_bar.max_value = max_health

func _input(event):	
	# Handle weapon inputs
	if dying:
		return
	if event.is_action_pressed("fire"):
		attack()
	if event.is_action_pressed("reload"):
		reload()
	if event.is_action_pressed("aim"):
		aim()
	if event.is_action_pressed("flashlight_toggle"):
		toggle_flashlight()
	# Handle number key presses for direct weapon selection
	for i in range(weapons.size()):
		if event.is_action_pressed("ui_select_" + str(i + 1)):
			switch_weapon_by_index(i)
			break
	# Handle mouse wheel for switching weapons
	if event.is_action_pressed("scroll_up"):
		var next_index = next_weapon_index(current_weapon_index, -1)
		switch_weapon_by_index(next_index)
	elif event.is_action_pressed("scroll_down"):
		var next_index = next_weapon_index(current_weapon_index, 1)
		switch_weapon_by_index(next_index)	
	if event.is_action_pressed("interact"):
		process_raycast()
	# Handle mouse input
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		$Head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		# Clamp the camera's vertical rotation
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90))



func _physics_process(delta):
	# Gravity logic
	if not is_on_floor():
		velocity.y -= gravity * delta
		falling = true
	if falling and is_on_floor():
		$StepAudio.play()
		falling = false
	# Handle jump
	if dying:
		return
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
		$Head/MainCamera.fov = lerp($Head/MainCamera.fov, SPRINT_FOV, 0.1)
		if stamina <= 0.0:
			stamina = 0.0  # Clamp stamina to zero
			is_sprinting = false
			can_sprint = false
	elif is_crouching:
		$StepTimer.wait_time = 1.2 
		$StepAudio.set_max_db(-10)
		$Head/MainCamera.global_transform.origin.y = lerp($Head/MainCamera.global_transform.origin.y, global_transform.origin.y - 0.5, delta * 10)
		speed = NORMAL_SPEED * CROUCH_MULTIPLIER
		can_sprint = false
		stamina += delta / 2
		stamina = min(stamina, MAX_STAMINA) 
	else:
		$StepTimer.wait_time = 0.6 
		$StepAudio.set_max_db(-7)
		$Head/MainCamera.global_transform.origin.y = lerp($Head/MainCamera.global_transform.origin.y, global_transform.origin.y, delta * 10)
		$Head/MainCamera.fov = lerp($Head/MainCamera.fov, NORMAL_FOV, 0.1)
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
	bob_head(delta)
	sway_head(delta, input_dir)
	# Getting slide collision
	for i in get_slide_collision_count():
		var c_object = get_slide_collision(i)
		if c_object.get_collider() is RigidBody3D and is_moving:
			c_object.get_collider().apply_central_impulse(-c_object.get_normal() * push_force)
			is_sprinting = false
			can_sprint = false
			break

func bob_head(delta):
	if not Graphics.bobbing: return
	bob_time += velocity.length() * float(is_on_floor()) * delta
	var pos = Vector3.ZERO
	pos.y = sin(bob_time * BOB_FREQUENCY) * BOB_AMPLITUDE - 0.5
	pos.x = cos(bob_time * BOB_FREQUENCY / 2) * (BOB_AMPLITUDE / 2)
	$Head/MainCamera.transform.origin = pos

func sway_head(delta, direction):
	var sway_angle = 2.5
	$Head.rotation.z = lerp_angle($Head.rotation.z, deg_to_rad(sway_angle * float(-direction.x)), 0.05)
	# $Head.rotation.x = lerp_angle($Head.rotation.x, deg_to_rad(sway_angle * float(-direction.y)), 0.05)

func _on_step_timer_timeout():
	if is_moving and is_on_floor():
		$StepAudio.pitch_scale = randf_range(0.8, 1.2)
		$StepAudio.play()

func attack():
	var weapon = get_current_weapon()
	if not weapon: return
	if weapon.ranged:
		if weapon.ammo > 0: weapon.shoot()
		else: $NoAmmo.play()
	else:
		weapon.swing()

func reload():
	var weapon = get_current_weapon()
	if weapon and weapon.ranged: weapon.reload()

func aim():
	var weapon = get_current_weapon()
	if weapon and weapon.ranged: weapon.aim()

func switch_weapon_by_index(index):
	if not can_switch: return
	
	if index in weapons and inventory[weapons.keys()[index]]["is_unlocked"]:
		current_weapon_index = index
		update_weapon_visibility()

func update_weapon_visibility():
	for i in weapons.keys():
		var weapon = weapons[i]
		if weapon: weapon.visible = i == current_weapon_index
	update_hitscan()
	%UI.update_ammo_count()
	%UI.update_crosshair()

func update_hitscan():
	var weapon = get_current_weapon()
	if weapon: $Head/MainCamera/HitScan.set_scale(weapons[current_weapon_index].range)

func get_current_weapon():
	return weapons[current_weapon_index]

func wrap_index(index):
	if index < 0: return weapons.size() - 1
	elif index >= weapons.size(): return 0
	else: return index

func next_weapon_index(current_index, direction):
	var attempts = 0
	var next_index = current_index
	while attempts < weapons.size():
		next_index += direction
		next_index = wrap_index(next_index)
		if inventory[weapons.keys()[next_index]]["is_unlocked"]:
			return next_index
		attempts += 1
	return current_index

func unlock_item(item_type):
	if not item_type in inventory: return
	var is_weapon = false
	if item_type in weapons and weapons[item_type]: is_weapon = true
	if not inventory[item_type]["is_unlocked"]:
		inventory[item_type]["is_unlocked"] = true 
		if is_weapon: add_ammo(item_type, weapons[item_type].max_ammo)
	elif is_weapon: add_ammo(item_type, weapons[item_type].max_ammo)
	%UI.update_ammo_count()

func add_ammo(weapon_type, amount):
	var weapon = weapons[weapon_type]
	inventory[weapon_type]["total_ammo"] += amount
	weapon.total_ammo = inventory[weapon_type]["total_ammo"]
	%UI.update_ammo_count()

func has_item(item_type):
	return inventory[item_type]["is_unlocked"]

func get_ammo(weapon_type):
	if inventory[weapon_type]["is_unlocked"]: return inventory[weapon_type]["total_ammo"] 
	else: return 0 
	%UI.update_ammo_count()

func toggle_flashlight():
	if not has_item(Items.FLASHLIGHT): return
	var flashlight = items[Items.FLASHLIGHT]
	if flashlight: $Head/MainCamera/Flashlight.toggle()

func apply_damage(damage, damage_type):
	health -= damage
	if not $Impact.is_playing():
		match damage_type:
			"axe": $Impact.set_stream(impact_sounds[0])
		$Impact.set_pitch_scale(randf_range(0.8, 1.2))
		$Impact.play()
	if not $Hurt.is_playing(): 
		var sound_to_play = hurt_sounds.pick_random()
		$Hurt.set_stream(sound_to_play)
		$Hurt.set_pitch_scale(randf_range(0.8, 1.2))
		$Hurt.play()
	if health <= 0: die()

func die():
	if not dying:
		dying = true
		$Death.play()
		%UI.fade_element($"../UI/BlackScreen", "modulate", Color("ffffff", 1), 3)
		$"../GunViewport".hide()
		speed = 0
		var tween = get_tree().create_tween()
		await get_tree().create_timer(3.0).timeout
		get_tree().reload_current_scene()

func process_raycast():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("action_used"):
			collider.action_used()
			print(collider)
