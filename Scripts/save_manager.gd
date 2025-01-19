extends Node

var save_path = "user://save_data.json"
var completed_levels: Array = []  # List of completed levels

# Save game data
func save_game_data(levels_to_save: Array):
	var save_data = {
		"completed_levels": levels_to_save
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

# Load game data
func load_game_data() -> Dictionary:
	var data = {
		"completed_levels": completed_levels
	}
		
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)  # Parse the JSON string back into a dictionary
		file.close()
		
		if parse_result == OK:
			var loaded_data = json.get_data()
			if loaded_data.has("completed_levels") and typeof(loaded_data.completed_levels) == TYPE_ARRAY:
				data.completed_levels = loaded_data.completed_levels
				completed_levels = data.completed_levels  # Assign the loaded levels to the class variable
	
	return data

# Reset game data (optional, for a new game)
func reset_game_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"completed_levels": []
	}))
	file.close()
