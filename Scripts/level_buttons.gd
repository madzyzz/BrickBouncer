extends Sprite2D

var is_mouse_within = false

func _on_area_2d_mouse_entered() -> void:
	is_mouse_within = true
	modulate = Color(1, 1, 1, 0.7)

func _on_area_2d_mouse_exited() -> void:
	is_mouse_within = false
	modulate = Color(1, 1, 1, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and is_mouse_within:
			# Change the scene directly when the button is clicked
			get_tree().change_scene_to_file("res://Scenes/level_1_scene.tscn")
