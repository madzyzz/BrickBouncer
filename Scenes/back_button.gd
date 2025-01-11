extends Button

func _ready() -> void:
	$BackArrow.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Opening_scene.tscn")


func _on_mouse_entered() -> void:
	modulate = Color(1, 1, 1, 0.7)


func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1, 1)


func _on_button_down() -> void:
	modulate = Color(1, 0.5, 0.5, 1)


func _on_button_up() -> void:
	modulate = Color(1, 1, 1, 1)
