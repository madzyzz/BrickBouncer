extends Node2D

@export var slot_count: int = 1  # Number of slots to create
@export var slot_spacing: float = 85.0  # Space between each slot (in pixels)
@onready var base_slot = $"Sprite2D"  # Reference to the initial slot (glass storage sprite)

func _ready() -> void:
	create_slots()

func create_slots() -> void:
	var last_position = base_slot.position
	for i in range(slot_count):
		var slot

		if i == 0:
			# Use the base slot for the first slot
			slot = base_slot
		else:
			# Duplicate the base slot for additional slots
			slot = base_slot.duplicate() as Sprite2D
			add_child(slot)

		# Position the slot to the right of the previous one
		slot.position = last_position + Vector2(slot_spacing, 0)
		last_position = slot.position

		# Ensure the slot is visible
		slot.visible = true
