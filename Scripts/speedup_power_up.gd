extends "res://Scripts/power_up.gd"

func on_collected(storage: Node2D):
	print("Speedup Powerup collected!")

	# Check if the powerup is already active
	if storage.active_powerups.has(powerup_type):
		print("Speedup Powerup is already active, resetting timer.")
		storage.add_powerup_to_slot(powerup_texture, powerup_type, true)  #bad powerup
		queue_free()
		return

	# Check if the powerup is already in a slot
	for filled in storage.filled_slots:
		if filled["type"] == powerup_type:
			print("Speedup Powerup is already in a slot but not active, ignoring.")
			return  # Do nothing; it's already in a slot

	# Attempt to add the powerup to a slot
	if storage.add_powerup_to_slot(powerup_texture, powerup_type, true):  # bad powerup
		print("Speedup Powerup added to storage!")
		queue_free()
	else:
		print("No available slots for Speedup Powerup, ignoring.")
		# Do nothing; let it continue falling


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bouncer":
		on_collected(body.glass_storage)

func on_powerup_activated(duration: float, ball: Node) -> void:
	print("Speedup Powerup activated for", duration, "seconds!")
	
	

func on_powerup_deactivated(ball: Node) -> void:
	print("Speedup Powerup deactivated!")
	

	
