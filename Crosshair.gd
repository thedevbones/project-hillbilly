extends Label

var fade_speed = 10.0
var target_alpha = 0.5

func _ready():
	modulate = Color(modulate.r, modulate.g, modulate.b, 0)

func _process(delta):
	var weapon = $"../Player".get_current_weapon()
	if weapon and not weapon.is_aiming:
		target_alpha = 1.0
	else:
		target_alpha = 0.0
	# Animate the fade
	modulate.a = lerp(modulate.a, target_alpha, fade_speed * delta)
