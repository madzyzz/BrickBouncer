extends StaticBody2D

# Current brick level (4 = strongest, 1 = weakest)
var brick_level: int = 4

@export var start_brick: int = 4

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
	# Update the sprite's texture based on the current brick level
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
	# Decrease the brick level when hit by the ball
	brick_level -= 1

	if brick_level > 0:
		# Update the texture for the new brick level
		update_texture()
	else:
		# Destroy the brick when its level reaches 0
		queue_free()
