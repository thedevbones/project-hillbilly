extends Label

func _process(_delta):
	var weapon = $"../Player".get_current_weapon()
	if weapon and weapon.ranged:
		text = str(weapon.ammo) + "/" + str(weapon.MAX_AMMO)
	else:
		text = " "