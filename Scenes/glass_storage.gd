extends Node2D

@export var slot_count: int = 3  # Number of slots to create
@export var slot_spacing: float = 85.0  # Space between each slot (in pixels)
@export var max_active_powerups: int = 1  # Maximum number of active powerups
@onready var base_slot = $"Sprite2D"  # Reference to the initial slot (glass storage sprite)

var slots = []  # Array to track all slots
var filled_slots = []  # Array to track filled slots (stores powerup types and textures)
var active_powerups = {}  # Tracks active powerups with their timers
var empty_slot_texture: Texture2D  # Texture for an empty slot

func _ready() -> void:
	# Store the texture of the base slot as the empty slot texture
	empty_slot_texture = base_slot.texture
	create_slots()

func create_slots() -> void:
	slots = []  # Clear previous slots
	filled_slots = []  # Clear filled slots
	active_powerups = {}  # Clear active powerups
	var last_position = base_slot.position

	for i in range(slot_count):
		var slot
		var area2d

		if i == 0:
			# Use the base slot for the first slot
			slot = base_slot
		else:
			# Duplicate the base slot for additional slots
			slot = base_slot.duplicate() as Sprite2D
			add_child(slot)

		# Add an Area2D for interaction
		area2d = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = RectangleShape2D.new()
		
		# Set the size of the hitbox to match the slot's texture size with scaling
		if slot.texture:
			var original_extents = slot.texture.get_size() / 2
			collision_shape.shape.extents = original_extents * 0.3  # Apply scale of 0.3

		# Add the CollisionShape2D to the Area2D
		area2d.add_child(collision_shape)
		add_child(area2d)

		# Position the slot and Area2D to the right of the previous one
		slot.position = last_position + Vector2(slot_spacing, 0)
		area2d.position = slot.position  # Align Area2D with the slot
		last_position = slot.position

		# Track the slot and connect its Area2D
		slots.append(slot)
		area2d.connect("input_event", Callable(self, "_on_slot_clicked").bind(i))

		# Ensure the slot is visible
		slot.visible = true

func add_powerup_to_slot(powerup_texture: Texture2D, powerup_type: String) -> bool:
	# Check if the powerup type already exists in a slot
	for filled in filled_slots:
		if filled["type"] == powerup_type:
			print("Powerup type already exists in a slot:", powerup_type)
			return true  # Simulate a successful pickup (for future timer reset)

	# Find the first empty slot
	for slot in slots:
		if not slot.get_meta("occupied", false):
			# Set the slot's texture and mark it as occupied
			slot.texture = powerup_texture
			slot.set_meta("occupied", true)

			# Add the powerup type and texture to filled slots
			filled_slots.append({ "type": powerup_type, "slot": slot })
			refresh_slot_appearance()  # Update slot visuals
			return true  # Powerup successfully added

	# No available slots
	return false

func _on_slot_clicked(viewport, event: InputEvent, shape_idx: int, slot_id: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Slot clicked:", slot_id)

		# Get the slot by its ID
		var slot = slots[slot_id]
		if slot.get_meta("occupied", false):
			# Get the powerup type associated with the slot
			for filled in filled_slots:
				if filled["slot"] == slot:
					activate_powerup(filled["type"], slot)

func activate_powerup(powerup_type: String, slot: Sprite2D) -> void:
	# Check if the maximum number of active powerups has been reached
	if active_powerups.size() >= max_active_powerups:
		print("Maximum active powerups reached!")
		return

	if active_powerups.has(powerup_type):
		print("Powerup already active:", powerup_type)
		return

	print("Activating powerup:", powerup_type)

	# Start the powerup timer
	var timer = Timer.new()
	timer.wait_time = get_powerup_duration(powerup_type)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_powerup_timeout").bind([powerup_type, slot]))
	add_child(timer)
	timer.start()

	active_powerups[powerup_type] = timer
	refresh_slot_appearance()  # Update slot visuals after activation

func get_powerup_duration(powerup_type: String) -> float:
	# Define durations for each powerup type (in seconds)
	match powerup_type:
		"metal_beam":
			return 5.0  # Example: 5 seconds
		"magnet":
			return 3.0  # Example: 3 seconds
		_:
			return 3.0  # Default duration

func _on_powerup_timeout(args: Array) -> void:
	var powerup_type = args[0]
	var slot = args[1]

	print("Powerup expired:", powerup_type)

	# Remove the powerup from the active list
	if active_powerups.has(powerup_type):
		active_powerups.erase(powerup_type)

	# Clear the slot
	if slot:
		slot.texture = empty_slot_texture  # Restore the original glass storage texture
		slot.set_meta("occupied", false)  # Mark the slot as available

	# Remove the powerup from filled_slots
	for filled in filled_slots:
		if filled["type"] == powerup_type:
			filled_slots.erase(filled)
			break

	refresh_slot_appearance()  # Update slot visuals after expiration

func refresh_slot_appearance() -> void:
	var can_activate_new = active_powerups.size() < max_active_powerups
	for filled in filled_slots:
		var slot = filled["slot"]
		var powerup_type = filled["type"]

		if active_powerups.has(powerup_type):
			# Active powerup slots are always dark
			slot.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			# Non-active slots reflect activatability
			slot.modulate = Color(1, 1, 1, 1) if can_activate_new else Color(0.5, 0.5, 0.5, 1)

