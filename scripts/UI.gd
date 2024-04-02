extends Control

@onready var crosshair = $Crosshair
@onready var ammo_count = $AmmoCount
@onready var wave_count = $WaveCount
@onready var wave_bar = $WaveBar
@onready var player = get_node_or_null("/root/World/Player")

var fade_speed = 10.0
var target_color = Color("ffffff", 0)

func _ready():
	crosshair.modulate = target_color
	wave_count.hide()
	wave_bar.max_value = $"../PrepTimer".get_wait_time()


func _process(delta):
	if wave_bar.value < wave_bar.max_value: 
		wave_bar.show()
	else: 
		wave_bar.hide()
	wave_bar.value = wave_bar.max_value - $"../PrepTimer".get_time_left()

func update_crosshair():
	if not player: return
	var weapon = player.get_current_weapon()
	var target_alpha = Color("ffffff", 0.5) if weapon and weapon.ranged and not weapon.is_aiming else Color("ffffff", 0)
	fade_element(crosshair, "modulate", target_alpha, 0.2)

func update_ammo_count():
	if not player: return
	var weapon = player.get_current_weapon()
	if weapon and weapon.ranged:
		ammo_count.text = str(weapon.ammo) + "/" + str(weapon.total_ammo)
	else:
		ammo_count.text = ""

func update_wave_count(wave):
	if not player: return
	if not wave_count.visible:
		wave_count.text = "Wave " + str(wave+1)
		wave_count.show()
		await get_tree().create_timer(5.0).timeout
		wave_count.hide()

func fade_element(object, property, final_val, duration):
	var tween = get_tree().create_tween()
	tween.tween_property(object, property, final_val, duration)
	tween.play()
