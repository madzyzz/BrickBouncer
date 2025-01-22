extends Node2D

@onready var bouncer = $"../Bouncer"
@onready var ball = $"../Ball"

@export var current_level: String  # Exported variable to set the current level name

func _on_child_exiting_tree(_node: Node) -> void:
	if get_child_count() <= 1:
		# Mark level as completed
		
		if not SaveManager.completed_levels.has(current_level):
			SaveManager.completed_levels.append(current_level)
			SaveManager.save_game_data(SaveManager.completed_levels)
			print("Level completed and saved:", current_level)
		
		# Clean up and show win screen
		if ball:
			ball.queue_free()
		if bouncer:
			bouncer.queue_free()
		$".".hide()
		$"../PowerupsHolder".hide()
		$"../GlassStorage".clear_powerups()
		$"../Game_won_screen".visible = true
