extends Button


func _on_pressed() -> void:
	SaveManager.reset_game_data()
	SaveManager.completed_levels = []
	get_tree().change_scene_to_file("res://Scenes/level_menu_scene.tscn")
