extends Button

func _on_pressed() -> void:
	var save_data = SaveManager.load_game_data()
	SaveManager.completed_levels = save_data.completed_levels
	get_tree().change_scene_to_file("res://Scenes/level_menu_scene.tscn")
