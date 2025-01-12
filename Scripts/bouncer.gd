extends CharacterBody2D

# Maximum speed of the bouncer (in pixels per second)
var max_speed = 500.0  

# Y position of the bouncer (constant)
var bouncer_y_position: float

# Snap threshold to stop vibration (in pixels)
var snap_threshold = 5.0

func _ready() -> void:
	# Lock the bouncer's Y position to its starting position
	bouncer_y_position = global_position.y

func _physics_process(delta: float) -> void:
	# Get the mouse's global X position
	var mouse_x = get_global_mouse_position().x

	# Calculate the horizontal direction toward the mouse
	var direction = mouse_x - position.x

	# If the distance to the mouse is greater than the threshold, move
	if abs(direction) > snap_threshold:
		velocity.x = max_speed * sign(direction)
	else:
		velocity.x = 0  # Stop moving if within the threshold

	# Apply the velocity and handle collisions
	move_and_slide()

	# Lock the Y position to the constant value
	position.y = bouncer_y_position
