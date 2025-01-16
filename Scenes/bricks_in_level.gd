extends Node2D

@onready var bouncer = $"../Bouncer"
@onready var ball = $"../Ball"

func _on_child_exiting_tree(_node: Node) -> void:
	if get_child_count() <= 1:
		ball.queue_free()
		bouncer.queue_free()
		$"../Game_won_screen".visible = true

