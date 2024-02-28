extends Node3D

# Pistol properties
const MAX_AMMO = 8
var ammo = MAX_AMMO
var is_reloading = false
var bullet_scene = preload("res://scene_object/bullet.tscn")
var BULLET_SPEED = 50.0
var RELOAD_TIME = 1.5

# Signals
signal shot_fired
signal reloaded

@onready var fire_audio = $Player/PistolFire

func shoot():
	if ammo > 0 and not is_reloading:
		# fire_audio.play()
		#var bullet_instance = bullet_scene.instance()
		#bullet_instance.global_transform = global_transform
		#bullet_instance.linear_velocity = -global_transform.basis.z.normalized() * BULLET_SPEED
		#get_tree().root.add_child(bullet_instance)
		ammo -= 1
		emit_signal("shot_fired")

func reload():
	if not is_reloading and ammo < MAX_AMMO:
		is_reloading = true
		await get_tree().create_timer(RELOAD_TIME).timeout
		ammo = MAX_AMMO
		is_reloading = false
		emit_signal("reloaded")
