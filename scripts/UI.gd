extends Control

@onready var crosshair = $Crosshair
@onready var ammo_count = $AmmoCount
@onready var wave_count = $WaveCount
@onready var player = get_node_or_null("/root/World/Player")

var fade_speed = 10.0
var target_alpha = 0.5

func _ready():
	var clear = Color(modulate.r, modulate.g, modulate.b, 0)
	crosshair.modulate = clear
	wave_count.modulate = clear
	update_ammo_count()

func update_crosshair():
	if not player: return
	var weapon = player.get_current_weapon()
	if weapon and weapon.ranged and not weapon.is_aiming:
		target_alpha = 0.5
	else:
		target_alpha = 0.0
	# Animate the fade
	crosshair.modulate.a = lerp(crosshair.modulate.a, target_alpha, fade_speed)

func update_ammo_count():
	if not player: return
	var weapon = player.get_current_weapon()
	if weapon and weapon.ranged:
		ammo_count.text = str(weapon.ammo) + "/" + str(weapon.total_ammo)
	else:
		ammo_count.text = " "

func update_wave_count():
	if not player: return
