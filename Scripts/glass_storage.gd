extends Node2D

@export var slot_count: int = 3  # Number of slots to create
@export var slot_spacing: float = 85.0  # Space between each slot (in pixels)
@export var max_active_powerups: int = 1  # Maximum number of active powerups
@onready var base_slot = $"Sprite2D"  # Reference to the initial slot (glass storage sprite)

var slots = []  # Array to track all slots
var filled_slots = []  # Array to track filled slots (stores powerup types and textures)
var active_powerups = {}  # Tracks active powerups with their timers
var empty_slot_texture: Texture2D  # Texture for an empty slot
var blink_timers = {}  # Tracks blinking timers for each slot
var remaining_times = {}

#powerup related stuff
var metal_beam_instance: Node = null

func _ready() -> void:
	# Store the texture of the base slot as the empty slot texture
	empty_slot_texture = base_slot.texture
	create_slots()

func create_slots() -> void:
	slots = []  # Clear previous slots
	filled_slots = []  # Clear filled slots
	active_powerups = {}  # Clear active powerups
	blink_timers = {}  # Clear blinking timers
	var last_position = base_slot.position

	for i in range(slot_count):
		var slot
		var area2d
		var label

		if i == 0:
			# Use the base slot for the first slot
			slot = base_slot
		else:
			# Duplicate the base slot for additional slots
			slot = base_slot.duplicate() as Sprite2D
			add_child(slot)

		# Add a Label for displaying the timer
		label = Label.new()
		label.name = "Label"
		label.text = ""  # Initially empty
		label.horizontal_alignment = 1  # CENTER
		label.vertical_alignment = 1    # CENTER

		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.custom_minimum_size = slot.texture.get_size() * slot.scale
		
		var font_file = load("res://fonts/dogica.ttf") as FontFile
		label.add_theme_font_override("font", font_file)
		label.add_theme_font_size_override("font_size", 60)

		label.set_anchor_and_offset(SIDE_LEFT, 0, -40)
		label.set_anchor_and_offset(SIDE_TOP, 0, 150)
		label.size = Vector2(1.2, 1.2)

		slot.add_child(label)  # Add the Label as a child of the slot

		# Add an Area2D for interaction
		area2d = Area2D.new()
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = RectangleShape2D.new()

		if slot.texture:
			var original_extents = slot.texture.get_size() / 2
			collision_shape.shape.extents = original_extents * 0.3  # Apply scale of 0.3

		area2d.add_child(collision_shape)
		add_child(area2d)

		slot.position = last_position + Vector2(slot_spacing, 0)
		area2d.position = slot.position
		last_position = slot.position

		slots.append(slot)
		area2d.connect("input_event", Callable(self, "_on_slot_clicked").bind(i))
		slot.visible = true


func get_powerup_duration(powerup_type: String) -> float:
	# Define durations for each powerup type (in seconds)
	match powerup_type:
		"metal_beam":
			return 10.0
		"magnet":
			return 15.0
		_:
			return 3.0  # Default duration

func add_powerup_to_slot(powerup_texture: Texture2D, powerup_type: String) -> bool:
	if active_powerups.has(powerup_type):
		print("Powerup already active, resetting timer:", powerup_type)

		# Reset remaining time
		remaining_times[powerup_type] = get_powerup_duration(powerup_type)

		# Restart the powerup's main timer
		var timer = active_powerups[powerup_type]["timer"]
		timer.start()

		# Restart the update timer for countdown
		var update_timer = active_powerups[powerup_type]["update_timer"]
		update_timer.start()

		# Ensure flickering resets to normal speed
		for filled in filled_slots:
			if filled["type"] == powerup_type:
				var slot = filled["slot"]
				if blink_timers.has(slot):
					var blink_timer = blink_timers[slot]
					blink_timer.wait_time = 0.5  # Reset to normal flickering speed
					blink_timer.start()
		return true


	# Check if the powerup type exists in a slot but is not active
	for filled in filled_slots:
		if filled["type"] == powerup_type:
			print("Powerup type already exists in a slot:", powerup_type)
			return true  # No further action needed if it's in a slot but not active

	# Find the first empty slot
	for slot in slots:
		if not slot.get_meta("occupied", false):
			# Add the powerup to the slot
			slot.texture = powerup_texture
			slot.set_meta("occupied", true)
			filled_slots.append({ "type": powerup_type, "slot": slot })
			refresh_slot_appearance()  # Update slot visuals
			return true

	# No available slots
	return false



func _on_slot_clicked(_viewport, event: InputEvent, _shape_idx: int, slot_id: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Slot clicked:", slot_id)
		var slot = slots[slot_id]

		# Check if the slot is occupied
		if slot.get_meta("occupied", false):
			var can_activate_new = active_powerups.size() < max_active_powerups
			var powerup_type = null

			# Find the powerup type associated with this slot
			for filled in filled_slots:
				if filled["slot"] == slot:
					powerup_type = filled["type"]
					break

			# Only flash and activate if the powerup can be activated
			if can_activate_new and powerup_type and not active_powerups.has(powerup_type):
				flash_slot_color(slot)
				activate_powerup(powerup_type, slot)
			else:
				print("Cannot activate powerup: either max active reached or already active.")


func activate_powerup(powerup_type: String, slot: Sprite2D) -> void:
	if active_powerups.size() >= max_active_powerups or active_powerups.has(powerup_type):
		return

	print("Activating powerup:", powerup_type)

	# Start the powerup timer
	var timer = Timer.new()
	timer.wait_time = get_powerup_duration(powerup_type)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_powerup_timeout").bind([powerup_type, slot]))
	add_child(timer)
	timer.start()

	# Start update timer for countdown display
	var update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.one_shot = false
	update_timer.connect("timeout", Callable(self, "_update_powerup_timer").bind([powerup_type, slot, update_timer]))
	add_child(update_timer)
	update_timer.start()

	# Track the powerup's timers and slot
	active_powerups[powerup_type] = { "timer": timer, "update_timer": update_timer, "slot": slot }
	remaining_times[powerup_type] = get_powerup_duration(powerup_type)

	# Display the initial timer value
	var label = slot.get_node("Label") as Label
	label.text = str(int(timer.wait_time))

	# Activate the powerup effect
	var bouncer = $"../Bouncer"
	var ball = $"../Ball"
	var script_path = "res://Scripts/" + powerup_type + "_power_up.gd"
	var powerup_script = load(script_path).new()
	
	if powerup_type == "metal_beam":
		powerup_script.on_powerup_activated(get_powerup_duration(powerup_type), bouncer)  # Pass the current node as context
	elif powerup_type == "magnet":
		powerup_script.on_powerup_activated(get_powerup_duration(powerup_type), bouncer, ball)


	start_blink(slot)
	refresh_slot_appearance()



func _on_powerup_timeout(args: Array) -> void:
	var powerup_type = args[0]
	var slot = args[1]
	if active_powerups.has(powerup_type):
		active_powerups.erase(powerup_type)
	stop_blink(slot)  # Stop blinking

	var label = slot.get_node("Label") as Label
	label.text = ""  # Clear the timer text

	slot.texture = empty_slot_texture
	slot.set_meta("occupied", false)
	for filled in filled_slots:
		if filled["type"] == powerup_type:
			filled_slots.erase(filled)
			break

	# Call the specific powerup's deactivation method
	var script_path = "res://Scripts/" + powerup_type + "_power_up.gd"
	var powerup_script = load(script_path).new()
	var bouncer = $"../Bouncer"
	var ball = $"../Ball"
	if powerup_type == "metal_beam":
		powerup_script.on_powerup_deactivated(bouncer)
	elif  powerup_type == "magnet":
		powerup_script.on_powerup_deactivated(bouncer, ball)
	else:
		powerup_script.on_powerup_deactivated()

	refresh_slot_appearance()



func refresh_slot_appearance() -> void:
	var can_activate_new = active_powerups.size() < max_active_powerups
	for filled in filled_slots:
		var slot = filled["slot"]
		var powerup_type = filled["type"]
		if active_powerups.has(powerup_type):
			start_blink(slot)
		else:
			stop_blink(slot)
			slot.modulate = Color(1, 1, 1, 1) if can_activate_new else Color(0.5, 0.5, 0.5, 1)

func start_blink(slot: Sprite2D) -> void:
	if blink_timers.has(slot):
		return
	var blink_timer = Timer.new()
	blink_timer.wait_time = 0.5
	blink_timer.one_shot = false
	blink_timer.connect("timeout", Callable(self, "_on_blink_timeout").bind(slot))
	add_child(blink_timer)
	blink_timer.start()
	blink_timers[slot] = blink_timer

func stop_blink(slot: Sprite2D) -> void:
	if blink_timers.has(slot):
		var blink_timer = blink_timers[slot]
		blink_timer.stop()
		blink_timer.queue_free()
		blink_timers.erase(slot)
	slot.modulate = Color(1, 1, 1, 1)

func _on_blink_timeout(slot: Sprite2D) -> void:
	slot.modulate = Color(1, 1, 1, 0.5) if slot.modulate == Color(1, 1, 1, 1) else Color(1, 1, 1, 1)

func flash_slot_color(slot: Sprite2D) -> void:
	slot.modulate = Color(0.3, 0.3, 0.3, 1)
	var flash_timer = Timer.new()
	flash_timer.wait_time = 0.3
	flash_timer.one_shot = true
	flash_timer.connect("timeout", Callable(self, "_on_flash_timeout").bind(slot))
	add_child(flash_timer)
	flash_timer.start()

func _on_flash_timeout(slot: Sprite2D) -> void:
	if active_powerups.has(slot.get_meta("powerup_type", "")):
		slot.modulate = Color(0.5, 0.5, 0.5, 1)
	else:
		slot.modulate = Color(1, 1, 1, 1)
		

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				trigger_slot_activation(0)  # First slot
			KEY_2:
				trigger_slot_activation(1)  # Second slot
			KEY_3:
				trigger_slot_activation(2)  # Third slot
			# Add more keys as needed for additional slots


func trigger_slot_activation(slot_id: int) -> void:
	if slot_id >= slot_count:
		print("Invalid slot number:", slot_id)
		return

	var slot = slots[slot_id]
	if slot.get_meta("occupied", false):
		var can_activate_new = active_powerups.size() < max_active_powerups
		var powerup_type = null

		# Find the powerup type associated with this slot
		for filled in filled_slots:
			if filled["slot"] == slot:
				powerup_type = filled["type"]
				break

		# Only flash and activate if the powerup can be activated
		if can_activate_new and powerup_type and not active_powerups.has(powerup_type):
			print("Key pressed to activate slot:", slot_id + 1)
			flash_slot_color(slot)  # Flash the slot as feedback
			activate_powerup(powerup_type, slot)
		else:
			print("Cannot activate powerup via key: either max active reached or already active.")

func _update_powerup_timer(args: Array) -> void:
	var powerup_type = args[0]
	var slot = args[1]
	var update_timer = args[2]

	if active_powerups.has(powerup_type) and remaining_times.has(powerup_type):
		# Safely reduce remaining time
		remaining_times[powerup_type] -= 1
		var remaining_time = remaining_times[powerup_type]

		# Update the label with the remaining time
		var label = slot.get_node("Label") as Label
		label.text = str(remaining_time)

		# Adjust blink speed for the last 2 seconds
		if remaining_time <= 2:
			if blink_timers.has(slot):
				var blink_timer = blink_timers[slot]
				blink_timer.wait_time = 0.15  # Faster flickering
				blink_timer.start()  # Restart to apply the new interval

		# Stop the update timer when the powerup expires
		if remaining_time <= 0:
			update_timer.stop()
			update_timer.queue_free()
			_on_powerup_timeout([powerup_type, slot])
	else:
		# Cleanup if the timer no longer exists
		update_timer.stop()
		update_timer.queue_free()


func clear_powerups() -> void:
	# Stop all active powerups
	for powerup_type in active_powerups.keys():
		
		var script_path = "res://Scripts/" + powerup_type + "_power_up.gd"
		var powerup_script = load(script_path).new()
		var bouncer = $"../Bouncer"
		var ball = $"../Ball"
		if powerup_type == "metal_beam":
			powerup_script.on_powerup_deactivated(bouncer)
		elif powerup_type == "magnet":
			powerup_script.on_powerup_deactivated(bouncer, ball)
		else:
			powerup_script.on_powerup_deactivated()
		print("Deactivating powerup:", powerup_type)
		
		var slot = active_powerups[powerup_type]["slot"]
		stop_blink(slot)  # Stop blinking

		# Reset the label text
		var label = slot.get_node("Label") as Label
		label.text = ""

		# Remove and free the powerup's main timer
		if active_powerups[powerup_type]["timer"]:
			var timer = active_powerups[powerup_type]["timer"]
			timer.stop()
			timer.queue_free()

		# Remove and free the update timer
		if active_powerups[powerup_type]["update_timer"]:
			var update_timer = active_powerups[powerup_type]["update_timer"]
			update_timer.stop()
			update_timer.queue_free()

	# Clear active powerups and remaining times
	active_powerups.clear()
	remaining_times.clear()

	# Reset all slots
	for slot in slots:
		slot.texture = empty_slot_texture  # Reset slot to empty texture
		slot.set_meta("occupied", false)  # Mark the slot as empty
		slot.modulate = Color(1, 1, 1, 1)  # Reset slot's appearance
		var label = slot.get_node("Label") as Label
		label.text = ""  # Ensure label is cleared

	filled_slots.clear()  # Clear the filled slots list
	refresh_slot_appearance()  # Update slot visuals




