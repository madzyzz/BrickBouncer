extends Button

@export var next_level_scene: String  # Export variable to set the next level scene path in the editor

func _on_pressed() -> void:
	get_tree().change_scene_to_file(next_level_scene)
