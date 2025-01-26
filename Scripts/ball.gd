extends RigidBody2D

var speed = 600.0
var is_shot = false
var is_locked = true  # Start with the ball locked to the bouncer
var ignore_bouncer_force_timer = 0.0  # Timer to temporarily ignore bouncer force

@onready var bouncer = $"../Bouncer"

# Powerup-related variables
var magnet_active = false
var ignore_magnet_timer: float = 0.0  # Timer to ignore magnet force temporarily
var ignore_duration: float = 0.1

func _ready() -> void:
	# Start with no movement and physics disabled
	linear_velocity = Vector2.ZERO
	sleeping = true  # Disable physics interactions while locked

func lock_to_bouncer(bouncer_pos: Vector2) -> void:
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
		apply_forces_from_magnets()  # Apply forces from magnets in the level

		if magnet_active:
			apply_powerup_magnetic_force()
		else:
			linear_velocity = linear_velocity.normalized() * speed

		process_overlapping_bricks()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_locked or ignore_bouncer_force_timer > 0:
		return  # Skip collision handling while locked or during delay

	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)

		if collider:
			if collider.name == "Bouncer":
				# Handle collision with the bouncer
				ignore_magnet_timer = ignore_duration

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

func apply_forces_from_magnets() -> void:
	# Loop through all magnets in the "Magnets" group
	for magnet in get_tree().get_nodes_in_group("Magnets"):
		if magnet and magnet.has_method("apply_magnetic_force"):
			magnet.apply_magnetic_force(self)  # Pass the ball as context




func process_overlapping_bricks() -> void:
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Bricks"):
			body.on_ball_collision()



func apply_powerup_magnetic_force() -> void:
	var bouncer_anim = $"../Bouncer/Bouncer_sprite_and_animations"
	# Reduce the ignore timer
	if ignore_magnet_timer > 0:
		ignore_magnet_timer -= get_physics_process_delta_time()
		bouncer_anim.play("Static_magnet")
		bouncer_anim.frame = 0
		return  # Skip magnetic pull while ignoring

	# Check vertical distance to limit magnetic effect
	if global_position.y - bouncer.global_position.y < -900:
		# Ball is too far above; maintain normal behavior
		linear_velocity = linear_velocity.normalized() * speed
		bouncer_anim.play("Static_magnet")
		bouncer_anim.frame = 0
	else:
		bouncer_anim.play("magnet_bouncer")
		
		# Calculate horizontal distance to the bouncer
		var distance_x = bouncer.global_position.x - global_position.x
		
		# Define magnet strength and damping
		var magnet_strength = 3.5  # Higher strength, but clamped
		var max_horizontal_speed = 350.0  # Prevent excessive horizontal speed
		
		# Adjust horizontal velocity based on magnetic pull
		var adjusted_velocity_x = clamp(distance_x * magnet_strength, -max_horizontal_speed, max_horizontal_speed)
		
		# Preserve the total speed by adjusting vertical velocity
		var total_speed = speed
		var adjusted_velocity_y = sqrt(max(total_speed**2 - adjusted_velocity_x**2, 0.01)) * sign(linear_velocity.y)

		# Apply the adjusted velocity
		linear_velocity.x = lerp(linear_velocity.x, adjusted_velocity_x, 0.2)
		linear_velocity.y = lerp(linear_velocity.y, adjusted_velocity_y, 0.2)

		
	
