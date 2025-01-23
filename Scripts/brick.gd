extends StaticBody2D

# Current brick level (4 = strongest, 1 = weakest)
var brick_level: int = 4

@export var start_brick: int = 4

@export var powerup_chance: float = 1.0  # Overall chance for any powerup to drop
@export var powerup_scenes: Array[PackedScene] = []  # Array of powerup scenes
@export var powerup_chances: Array[float] = []  # Array of drop chances for each powerup

# Preloaded textures for each brick level
@export var brick_4_texture: Texture2D
@export var brick_3_texture: Texture2D
@export var brick_2_texture: Texture2D
@export var brick_1_texture: Texture2D

func _ready() -> void:
	brick_level = start_brick
	update_texture()

	$Sprite2D.scale = Vector2(0.43, 0.457)
	$CollisionShape2D.scale = Vector2(0.47, 0.49)

func update_texture() -> void:
	match brick_level:
		4:
			$Sprite2D.texture = brick_4_texture
		3:
			$Sprite2D.texture = brick_3_texture
		2:
			$Sprite2D.texture = brick_2_texture
		1:
			$Sprite2D.texture = brick_1_texture

func on_ball_collision():
	brick_level -= 1

	if brick_level > 0:
		spawn_powerup()
		update_texture()
	else:
		spawn_powerup()
		queue_free()

func spawn_powerup() -> void:
	# Check overall chance to drop any powerup
	if randf() < powerup_chance and powerup_scenes.size() == powerup_chances.size():
		# Total weight for individual powerup chances
		var total_chance = 0.0
		for chance in powerup_chances:
			total_chance += chance

		# If total_chance is 0, prevent any powerup from spawning
		if total_chance <= 0.0:
			return

		# Pick a random value within the total weight
		var random_pick = randf() * total_chance
		var accumulated_chance = 0.0

		# Determine which powerup to drop
		for i in range(powerup_chances.size()):
			accumulated_chance += powerup_chances[i]
			if random_pick <= accumulated_chance:
				# Find the powerups_holder node
				var powerups_holder = $"../../PowerupsHolder"
				if powerups_holder:
					# Instantiate the selected powerup
					var powerup_instance = powerup_scenes[i].instantiate()
					powerups_holder.add_child(powerup_instance)
					powerup_instance.global_position = global_position
				else:
					print("Error: powerups_holder node not found!")
				return  # Only one powerup drops


