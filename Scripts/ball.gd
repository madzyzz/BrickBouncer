extends RigidBody2D

var speed = 600.0
var is_shot = false
var collision_delay_timer = 0.0

func _ready() -> void:
	linear_velocity = Vector2.ZERO

func shoot_ball(target_position: Vector2) -> void:
	if not is_shot:
		# Launch the ball toward the target position
		var direction = (target_position - global_position).normalized()
		linear_velocity = direction * speed
		is_shot = true
		collision_delay_timer = 0.2  # 200ms delay before bouncer can affect the ball

func _physics_process(delta: float) -> void:
	if is_shot:
		# Decrease the collision delay timer
		if collision_delay_timer > 0:
			collision_delay_timer -= delta

		# Maintain a consistent speed
		linear_velocity = linear_velocity.normalized() * speed

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in range(state.get_contact_count()):
		# Get the collider object for this collision
		var collider = state.get_contact_collider_object(i)

		if collider and collider.name == "Bouncer":
			# Skip collision adjustments during the delay
			if collision_delay_timer > 0:
				continue

			# Get the collision point and the bouncer's position
			var collision_point = state.get_contact_collider_position(i)
			var bouncer_position = collider.global_position

			# Calculate the bounce direction
			var direction = (collision_point - bouncer_position).normalized()

			# Balance horizontal and vertical components
			direction.x *= 1.2  # Moderate horizontal deflection
			direction.y *= 2.0  # Prioritize upward movement
			direction = direction.normalized()

			# Update the ball's velocity
			linear_velocity = direction * speed
