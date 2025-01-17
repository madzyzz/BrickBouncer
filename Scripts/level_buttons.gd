extends Sprite2D

@export var level_scene: String  # The scene to load when the button is clicked
@export var required_level: String  # The level required to unlock this button

var is_mouse_within = false
var is_unlocked = false  # Whether this level is unlocked

func _ready() -> void:
	# Check if the required level is completed
	if required_level == "" or SaveManager.completed_levels.has(required_level):
		is_unlocked = true
		modulate = Color(1, 1, 1, 1)  # Full opacity for unlocked levels
	else:
		is_unlocked = false
		modulate = Color(0.5, 0.5, 0.5, 1)  # Dimmed appearance for locked levels

func _on_area_2d_mouse_entered() -> void:
	if is_unlocked:
		is_mouse_within = true
		modulate = Color(1, 1, 1, 0.7)  # Make the button semi-transparent when hovered

func _on_area_2d_mouse_exited() -> void:
	if is_unlocked:
		is_mouse_within = false
		modulate = Color(1, 1, 1, 1)  # Reset to full opacity when the mouse leaves

func _process(_delta: float) -> void:
	# Check if the mouse is actually over the button
	var mouse_pos = get_global_mouse_position()
	var is_mouse_actually_within = _is_mouse_over_button(mouse_pos)
	
	if is_unlocked:  # Only update hover behavior for unlocked buttons
		if is_mouse_within and not is_mouse_actually_within:
			_on_area_2d_mouse_exited()
		elif not is_mouse_within and is_mouse_actually_within:
			_on_area_2d_mouse_entered()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_mouse_within:
		if is_unlocked:
			get_tree().change_scene_to_file(level_scene)
		else:
			print("This level is locked!")

func _is_mouse_over_button(mouse_pos: Vector2) -> bool:
	if texture:
		# Adjust the size and radius of the circle
		var texture_size = texture.get_size() * 0.2  # Scale the texture size if needed
		var radius = texture_size.x / 2  # Assuming the texture is square (or use min dimension)
		var center = global_position  # Center of the circle is the node's global position
		
		# Check if the mouse is within the circle
		return mouse_pos.distance_to(center) <= radius
	return false
