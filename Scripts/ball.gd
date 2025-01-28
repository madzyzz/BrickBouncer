extends RigidBody2D

var speed = 600.0
var is_shot = false
var is_locked = true  # Start with the ball locked to the bouncer
var ignore_bouncer_force_timer = 0.0  # Timer to temporarily ignore bouncer force
var lock_tolerance: float = 1.0
@onready var bouncer = $"../Bouncer"

var original_position = null

# Powerup-related variables
var magnet_active = false
var ignore_magnet_timer: float = 0.0  # Timer to ignore magnet force temporarily
var ignore_duration: float = 0.1

var negative_magnet_active = false

# Mechanic related variables
var laser_kill = false

func _ready() -> void:
	# Start with no movement and physics disabled
	global_position = Vector2(360, 1138)
	original_position = global_position
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
		if abs(global_position.x - original_position.x) > 2 or abs(global_position.y - original_position.y) > 2:
			print("adjusting ball shooting position")
			global_position = Vector2(360, 1138)
		return  # Skip physics updates while locked

	if ignore_bouncer_force_timer > 0:
		ignore_bouncer_force_timer -= delta

	ensure_minimum_vertical_velocity()

	if is_shot:
		apply_forces_from_magnets()  # Apply forces from magnets in the level

		if magnet_active:
			apply_powerup_magnetic_force()
		elif negative_magnet_active:
			apply_negative_magnetic_force()
		else:
			linear_velocity = linear_velocity.normalized() * speed

		process_overlapping_bricks()

func ensure_minimum_vertical_velocity():
	var min_vertical_velocity = 120.0  # Adjust this value during testing
	if abs(linear_velocity.y) < min_vertical_velocity:
		if speed < 899:
		# Add or subtract velocity to ensure vertical movement
			linear_velocity.y += sign(linear_velocity.y) * min_vertical_velocity
			if linear_velocity.y == 0:
				linear_velocity.y = min_vertical_velocity
			print("Adjusted vertical velocity to avoid horizontal bouncing:", linear_velocity.y)

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

			elif collider.name == "Death_border" or collider.name == "LaserBeam2D":
				print(collider.name)
				var level_setup = $".."
				if level_setup:
					sleeping = true
					linear_velocity = Vector2.ZERO
					level_setup.lose_life()
			
			
	if laser_kill == true:
		var level_setup = $".."
		if level_setup:
			sleeping = true
			linear_velocity = Vector2.ZERO
			level_setup.lose_life()
			laser_kill = false

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

		
func apply_negative_magnetic_force() -> void:
	var bouncer_anim = $"../Bouncer/Bouncer_sprite_and_animations"
	
	# Reduce the ignore timer
	if ignore_magnet_timer > 0:
		ignore_magnet_timer -= get_physics_process_delta_time()
		bouncer_anim.play("Static_magnet")
		bouncer_anim.frame = 0
		return  # Skip magnetic push while ignoring

	# Check vertical distance to limit magnetic effect
	if global_position.y - bouncer.global_position.y < -450:
		# Ball is too far above; maintain normal behavior
		linear_velocity = linear_velocity.normalized() * speed
		bouncer_anim.play("Static_magnet")
		bouncer_anim.frame = 0
	else:
		bouncer_anim.play("Negative_magnet")
		
		# Calculate the horizontal push force
		var magnet_push_force = 2.0  # Base push force
		var distance_x = global_position.x - bouncer.global_position.x

		# Scale push force based on current horizontal velocity
		var horizontal_factor = abs(linear_velocity.x) / speed
		var adjusted_push_force = magnet_push_force * (1.0 - horizontal_factor)

		# Final horizontal force, considering current velocity
		var push_force_x = clamp(distance_x * adjusted_push_force, -speed, speed)

		# Gradually adjust the horizontal velocity
		linear_velocity.x = lerp(linear_velocity.x, push_force_x, 0.1)

		# Preserve vertical velocity while ensuring a minimum
		var min_vertical_velocity = 400  # Prevent vertical stalling
		if abs(linear_velocity.y) < min_vertical_velocity:
			linear_velocity.y = sign(linear_velocity.y) * min_vertical_velocity



