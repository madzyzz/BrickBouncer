extends "res://Scripts/power_up.gd"

var metal_beam_instance: Node = null  # To track the MetalBeam instance
var metal_beam_scene = load("res://prefabs/metal_beam.tscn")

func on_collected(storage: Node2D):
	print("Metal Beam Powerup collected!")

	# Check if the powerup is already active
	if storage.active_powerups.has(powerup_type):
		print("Metal Beam Powerup is already active, resetting timer.")
		storage.add_powerup_to_slot(powerup_texture, powerup_type)  # Reset timer
		queue_free()
		return

	# Check if the powerup is already in a slot
	for filled in storage.filled_slots:
		if filled["type"] == powerup_type:
			print("Metal Beam Powerup is already in a slot but not active, ignoring.")
			return  # Do nothing; it's already in a slot

	# Attempt to add the powerup to a slot
	if storage.add_powerup_to_slot(powerup_texture, powerup_type):
		print("Metal Beam Powerup added to storage!")
		queue_free()
	else:
		print("No available slots for Metal Beam Powerup, ignoring.")
		# Do nothing; let it continue falling

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bouncer":
		on_collected(body.glass_storage)
		

func on_powerup_activated(duration: float, bouncer: Node) -> void:
	print("Metal Beam activated for", duration, "seconds!")

	# Instantiate and position the MetalBeam
	if not metal_beam_instance:
		metal_beam_instance = metal_beam_scene.instantiate()
		if bouncer:
			metal_beam_instance.global_position = global_position + Vector2(251, 1188)
			bouncer.get_parent().add_child(metal_beam_instance)

func on_powerup_deactivated(bouncer: Node) -> void:
	print("Metal Beam deactivated!")
	for child in bouncer.get_parent().get_children():
		if child.name == "MetalBeam":
			var metalBeam = child
			metalBeam.queue_free()
			metalBeam = null
