extends "res://Scripts/power_up.gd"

func on_collected(storage: Node2D):
	print("Magnet Powerup collected!")

	# Check if the powerup is already active
	if storage.active_powerups.has(powerup_type):
		print("Magnet Powerup is already active, resetting timer.")
		storage.add_powerup_to_slot(powerup_texture, powerup_type)  # Reset timer
		queue_free()
		return

	# Check if the powerup is already in a slot
	for filled in storage.filled_slots:
		if filled["type"] == powerup_type:
			print("Magnet Powerup is already in a slot but not active, ignoring.")
			return  # Do nothing; it's already in a slot

	# Attempt to add the powerup to a slot
	if storage.add_powerup_to_slot(powerup_texture, powerup_type):
		print("Magnet Powerup added to storage!")
		queue_free()
	else:
		print("No available slots for Magnet Powerup, ignoring.")
		# Do nothing; let it continue falling

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bouncer":
		on_collected(body.glass_storage)
		
func on_powerup_activated(duration: float, bouncer: Node) -> void:
	print("Metal Beam activated for", duration, "seconds!")

func on_powerup_deactivated() -> void:
	print("Metal Beam deactivated!")
