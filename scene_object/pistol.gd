extends Node3D

# Pistol properties
const MAX_AMMO = 8
const BULLET_SPEED = 50.0
const RELOAD_TIME = 1.5
var ammo = MAX_AMMO
var is_reloading = false
var bullet_scene = preload("res://scene_object/bullet.tscn")

@onready var camera = $".."

# Signals
signal shot_fired
signal reloaded

func shoot():
	if ammo > 0 and not is_reloading:
		# Play fire sound
		$PistolFire.play()
		# Flash muzzle flash light
		$MuzzleLight.show()
		await get_tree().create_timer(0.1).timeout
		$MuzzleLight.hide()
		# Create and initialize bullet
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.initialize_bullet(-camera.global_transform.basis.z.normalized() * BULLET_SPEED, self.global_transform)
		get_tree().root.add_child(bullet_instance)
		# Adjust ammo
		ammo -= 1
		emit_signal("shot_fired")

func reload():
	if not is_reloading and ammo < MAX_AMMO:
		is_reloading = true
		$PistolReload.play()
		await get_tree().create_timer(RELOAD_TIME).timeout
		ammo = MAX_AMMO
		is_reloading = false
		emit_signal("reloaded")
