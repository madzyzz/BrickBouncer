extends "res://Scripts/power_up.gd"

@export var magnet_force: float = 0.2  # Force applied by the magnet
@export var active_magnet_distance: float = 300.0 # Maximum distance to apply the magnetic pull

func on_collected(storage: Node2D):
	print("Magnet Powerup collected!")

	# Check if the powerup is already active
	if storage.active_powerups.has(powerup_type):
		print("Magnet Powerup is already active, resetting timer.")
		storage.add_powerup_to_slot(powerup_texture, powerup_type)  # Reset timer, not a bad powerup
		queue_free()
		return

	# Check if the powerup is already in a slot
	for filled in storage.filled_slots:
		if filled["type"] == powerup_type:
			print("Magnet Powerup is already in a slot but not active, ignoring.")
			return  # Do nothing; it's already in a slot

	# Attempt to add the powerup to a slot
	if storage.add_powerup_to_slot(powerup_texture, powerup_type):  # Not a bad powerup
		print("Magnet Powerup added to storage!")
		queue_free()
	else:
		print("No available slots for Magnet Powerup, ignoring.")
		# Do nothing; let it continue falling


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bouncer":
		on_collected(body.glass_storage)

func on_powerup_activated(duration: float, bouncer: Node, ball: Node) -> void:
	print("Magnet Powerup activated for", duration, "seconds!")
	
	ball.magnet_active = true
	var bouncer_anim = bouncer.get_child(0)
	bouncer_anim.play("Static_magnet")
	
	bouncer.hitbox.global_position += Vector2(0, -10)
	bouncer.y_offset = 10
	
	

func on_powerup_deactivated(bouncer: Node, ball: Node) -> void:
	print("Magnet Powerup deactivated!")
	
	ball.magnet_active = false
	var bouncer_anim = bouncer.get_child(0)
	bouncer_anim.play("Ball_hits_bouncer")
	bouncer_anim.frame = 2
	
	bouncer.hitbox.global_position -= Vector2(0, -10)
	bouncer.y_offset = 0

	
