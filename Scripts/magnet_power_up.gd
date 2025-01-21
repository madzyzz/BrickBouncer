extends "res://Scripts/power_up.gd"

func on_collected(storage: Node2D):
	print("Magnet Powerup collected!")
	if storage.add_powerup_to_slot(powerup_texture, powerup_type):
		print("Powerup added to storage or duplicate handled!")
		queue_free()
	else:
		print("No available slots for Magnet Powerup!")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bouncer":
		on_collected(body.glass_storage)
