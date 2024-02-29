extends StaticBody3D

func apply_damage(damage):
	change_color()

# Example function, later to be create blood or other FX
func change_color():
	var mesh_instance = $MeshInstance3D # Adjust the path to your MeshInstance3D node
	var new_color = Color(randf(), randf(), randf(), 1) # Generate a random color
	mesh_instance.get_active_material(0).albedo_color = new_color
