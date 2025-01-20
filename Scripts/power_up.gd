extends Area2D

@export var fall_speed: float = 200.0  # Speed at which the powerup falls
@export var powerup_type: String  # Identifier for the powerup type (e.g., "extra_life", "multi_ball")

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	global_position += Vector2(0, fall_speed * delta)

	# Remove the powerup if it goes off-screen
	if global_position.y > get_viewport_rect().size.y:
		queue_free()

func on_collected():
	# Placeholder for specific powerup behavior
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bouncer":
		on_collected()
