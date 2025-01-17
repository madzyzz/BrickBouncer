extends Node

var completed_levels: Array = []  # Array to store completed level names

# Save completed levels to a file
func save_game():
	var save_data = {
		"completed_levels": completed_levels
	}
	var json_data = JSON.new().stringify(save_data)  # Convert the dictionary to a JSON string
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(json_data)
	file.close()

# Load completed levels from a file
func load_game():
	if FileAccess.file_exists("user://save_game.json"):  # Check if the file exists
		var file = FileAccess.open("user://save_game.json", FileAccess.READ)
		var json_data = file.get_as_text()
		file.close()

		var json_instance = JSON.new()  # Create an instance of the JSON class
		var parse_result = json_instance.parse(json_data)  # Parse the JSON string into a dictionary

		if parse_result == OK:
			completed_levels = json_instance.result.get("completed_levels", [])
