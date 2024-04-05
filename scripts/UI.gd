extends Control

@onready var crosshair = $Crosshair
@onready var ammo_count = $AmmoCount
@onready var wave_count = $WaveCount
@onready var wave_bar = $WaveBar
@onready var black_screen = $BlackScreen
@onready var upgrade_prompt = $UpgradePrompt
@onready var health_bar = $HealthBar
@onready var player = get_node_or_null("/root/World/Player")

func _ready():
	black_screen.show()
	crosshair.modulate = Color("ffffff", 0)
	wave_count.modulate = Color("ffffff", 0)
	upgrade_prompt.modulate = Color("ffffff", 0)
	health_bar.modulate = Color("ffffff", 0)
	wave_bar.max_value = $"../PrepTimer".get_wait_time()
	fade_element(black_screen, "modulate", Color("ffffff", 0), 1.5)

func _process(delta):
	if wave_bar.value < wave_bar.max_value: 
		wave_bar.show()
	else: 
		wave_bar.hide()
	wave_bar.value = wave_bar.max_value - $"../PrepTimer".get_time_left()
	
	if health_bar.value < health_bar.max_value: 
		fade_element(health_bar, "modulate", Color("ffffff", 1), 0.5)
	else: 
		fade_element(health_bar, "modulate", Color("ffffff", 0), 1.0)
	health_bar.value = player.health

func update_crosshair():
	if not player: return
	var weapon = player.get_current_weapon()
	var target_color = Color("ffffff", 0.5) if weapon and weapon.ranged and not weapon.is_aiming else Color("ffffff", 0)
	fade_element(crosshair, "modulate", target_color, 0.2)

func update_ammo_count():
	if not player: return
	var weapon = player.get_current_weapon()
	if weapon and weapon.ranged:
		ammo_count.text = str(weapon.ammo) + "/" + str(weapon.total_ammo)
	else:
		ammo_count.text = ""

func update_wave_count(wave):
	if not player: return
	if wave_count.modulate.a == 0.0:
		$WaveSound.play()
		wave_count.text = "Wave " + str(wave+1)
		fade_element(wave_count, "modulate", Color("ffffff", 1), 0.5)
		await get_tree().create_timer(3.0).timeout
		fade_element(wave_count, "modulate", Color("ffffff", 0), 1.0)

func update_upgrade_prompt():
	if upgrade_prompt.modulate.a == 0.0:
		fade_element(upgrade_prompt, "modulate", Color("ffffff", 1), 0.5)
		await get_tree().create_timer(5.0).timeout
		fade_element(upgrade_prompt, "modulate", Color("ffffff", 0), 1.0)

func fade_element(object, property, final_val, duration):
	var tween = get_tree().create_tween()
	tween.tween_property(object, property, final_val, duration)
