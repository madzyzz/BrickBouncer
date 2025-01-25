extends Area2D

@export var fall_speed: float = 200.0  # Speed at which the powerup falls
@export var powerup_texture: Texture2D  # Texture for the powerup's slot icon
@export var powerup_type: String
@export var is_bad_powerup: bool = false

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	global_position += Vector2(0, fall_speed * delta)

	# Remove the powerup if it goes off-screen
	if global_position.y > get_viewport_rect().size.y:
		queue_free()
	
