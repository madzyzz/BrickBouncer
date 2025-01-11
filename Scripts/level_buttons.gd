extends Sprite2D

var is_mouse_within = false
var is_button_pressed = false

func _on_area_2d_mouse_entered() -> void:
	is_mouse_within = true
	modulate = Color(1, 1, 1, 0.7)  # Make the button semi-transparent when hovered

func _on_area_2d_mouse_exited() -> void:
	is_mouse_within = false
	modulate = Color(1, 1, 1, 1)  # Reset to full opacity when the mouse leaves

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var is_mouse_actually_within = _is_mouse_over_button(mouse_pos)
	
	if is_mouse_within and not is_mouse_actually_within:
		# Mouse has left the button but the exit signal did not fire
		_on_area_2d_mouse_exited()
	elif not is_mouse_within and is_mouse_actually_within:
		# Mouse has entered the button but the entered signal did not fire
		_on_area_2d_mouse_entered()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and is_mouse_within:
		if event.pressed:
			get_tree().change_scene_to_file("res://Scenes/level_1_scene.tscn")


func _is_mouse_over_button(mouse_pos: Vector2) -> bool:
	if texture:
		# Adjust the size and radius of the circle
		var texture_size = texture.get_size() * 0.2  # Scale the texture size if needed
		var radius = texture_size.x / 2  # Assuming the texture is square (or use min dimension)
		var center = global_position  # Center of the circle is the node's global position
		
		# Check if the mouse is within the circle
		return mouse_pos.distance_to(center) <= radius
	return false
