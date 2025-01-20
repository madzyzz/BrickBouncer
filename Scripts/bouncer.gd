extends CharacterBody2D

var max_speed = 500.0  
var bouncer_y_position: float
var snap_threshold = 5.0

@onready var ball = $"../Ball"  # Reference the pre-existing ball in the scene
@onready var dotted_line = $DottedLine  # Reference to the dotted line node
var is_ball_shot = false

# Define shooting angle limits (in radians)
var min_angle = deg_to_rad(-150)  # Limit shooting to -150° left
var max_angle = deg_to_rad(-30)   # Limit shooting to -30° right


func _ready() -> void:
	bouncer_y_position = global_position.y

	# Initialize the ball
	ball.global_position = global_position + Vector2(0, 10)
	ball.is_locked = true
	ball.sleeping = true

	# Ensure the dotted line is visible initially
	dotted_line.visible = true

func _physics_process(_delta: float) -> void:
	# Lock the bouncer and ball in place if the ball is not shot
	if not is_ball_shot:
		velocity.x = 0
		move_and_slide()
		position.y = bouncer_y_position

		# Lock the ball to the bouncer
		ball.lock_to_bouncer(global_position)

		# Update the dotted line to point towards the mouse
		update_dotted_line()
		return

	# Move the bouncer after the ball is shot
	var mouse_x = get_global_mouse_position().x
	var direction = mouse_x - position.x

	if abs(direction) > snap_threshold:
		velocity.x = max_speed * sign(direction)
	else:
		velocity.x = 0

	move_and_slide()
	position.y = bouncer_y_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not is_ball_shot:
		# Shoot the ball and unlock the bouncer
		ball.shoot_ball(get_clamped_mouse_position())
		is_ball_shot = true

		# Hide the dotted line after the ball is shot
		dotted_line.visible = false

func update_dotted_line() -> void:
	# Calculate clamped direction
	var mouse_position = get_clamped_mouse_position()
	var direction = mouse_position - ball.global_position

	# Update the dotted line's position and rotation
	dotted_line.global_position = ball.global_position + Vector2(1, -50)
	dotted_line.rotation = direction.angle() + deg_to_rad(90)

func get_clamped_mouse_position() -> Vector2:
	# Get the mouse position and calculate the direction vector
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - ball.global_position
	var angle = direction.angle()

	# Check if the mouse is between the min and max angles
	if min_angle <= angle and angle <= max_angle:
		return mouse_position  # Mouse is within the valid range, no clamping needed

	# Determine if the mouse is on the left or right side
	if mouse_position.x < ball.global_position.x:
		# Mouse is on the left side
		return ball.global_position + Vector2(cos(min_angle), sin(min_angle)) * direction.length()
	else:
		# Mouse is on the right side
		return ball.global_position + Vector2(cos(max_angle), sin(max_angle)) * direction.length()
		

func _on_collision_polygon_2d_body_entered(body: Node2D) -> void:
	if body.has_method("on_collected"):  # Check if the body is a powerup
		body.on_collected()
		emit_signal("powerup_collected", body.powerup_type)
		print("Collected powerup:", body.powerup_type)
