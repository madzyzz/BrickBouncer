extends Node2D


func _on_child_exiting_tree(_node: Node) -> void:
	if get_child_count() <= 1:
		print("The node is empty now!")

