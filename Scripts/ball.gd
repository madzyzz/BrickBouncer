extends RigidBody2D

var speed = 600.0
var is_shot = false
var is_locked = true  # Start with the ball locked to the bouncer
var bouncer_position: Vector2  # Track the bouncer's position
var ignore_bouncer_force_timer = 0.0  # Timer to temporarily ignore bouncer force

func _ready() -> void:
	# Start with no movement and physics disabled
	linear_velocity = Vector2.ZERO
	sleeping = true  # Disable physics interactions while locked

func lock_to_bouncer(bouncer_pos: Vector2) -> void:  # Renamed parameter to "bouncer_pos"
	if is_locked:
		# Keep the ball visually locked to the bouncer
		global_position = bouncer_pos + Vector2(0, 0)

func shoot_ball(target_position: Vector2) -> void:
	if is_locked:
		# Unlock the ball and enable physics
		is_locked = false
		sleeping = false  # Enable physics interactions
		ignore_bouncer_force_timer = 0.1  # Delay bouncer force for 100ms
		linear_velocity = Vector2.ZERO  # Clear residual forces
		var direction = (target_position - global_position).normalized()
		linear_velocity = direction * speed
		is_shot = true

func _physics_process(delta: float) -> void:
	if is_locked:
		return  # Skip physics updates while locked

	if ignore_bouncer_force_timer > 0:
		ignore_bouncer_force_timer -= delta

	if is_shot:
		# Maintain a consistent speed
		linear_velocity = linear_velocity.normalized() * speed

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_locked or ignore_bouncer_force_timer > 0:
		return  # Skip collision handling while locked or during delay

	for i in range(state.get_contact_count()):
		# Get the collider object for this collision
		var collider = state.get_contact_collider_object(i)

		if collider:
			if collider.name == "Bouncer":
				# Handle collision with the bouncer
				var bouncer_animation = $"../Bouncer/Bouncer_sprite_and_animations"
				bouncer_animation.frame = 1
				bouncer_animation.play()
				
				var collision_point = state.get_contact_collider_position(i)
				var collider_bouncer_position = collider.global_position

				# Calculate the bounce direction
				var direction = (collision_point - collider_bouncer_position).normalized()
				direction.x *= 1.1  # Moderate horizontal direction
				direction.y *= 2.0  # Prioritize upward movement
				direction = direction.normalized()
				linear_velocity = direction * speed
			
			elif collider.name == "Death_border":
				var level_setup = $".."
				if level_setup:
					level_setup.lose_life()
			
			elif collider.is_in_group("Bricks"):
				collider.on_ball_collision()


