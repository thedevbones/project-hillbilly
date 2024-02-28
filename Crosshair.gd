extends Label

func _process(_delta):
	var weapon = $"../Player".get_current_weapon()
	if weapon:
		show()
	else:
		hide()
