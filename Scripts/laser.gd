extends RayCast2D

# Speed at which the laser extends when first fired, in pixels per seconds.
@export var cast_speed := 7000.0
# Maximum length of the laser in pixels.
@export var max_length := 750.0
# Base duration of the tween animation in seconds.
@export var growth_time := 0.1

@export var use_delayed_activation: bool = false
@export var activation_delay: float = 1.0

# If `true`, the laser is firing.
# It plays appearing and disappearing animations when it's not animating.
# See `appear()` and `disappear()` for more information.
var is_casting := false: set = set_is_casting
var activation_timer: Timer

@onready var fill : Line2D = $FillLine2D
var tween : Tween
@onready var casting_particles := $CastingParticles2D
@onready var collision_particles := $CollisionParticles2D
@onready var beam_particles := $BeamParticles2D

@onready var line_width: float = fill.width


func _ready() -> void:
	# Ensure the laser is always active
	is_casting = not use_delayed_activation
	fill.points[1] = Vector2.ZERO  # Reset beam to start
	set_physics_process(is_casting)  # Start physics updates if not already running
	
	if use_delayed_activation:
		activation_timer = Timer.new()
		activation_timer.one_shot = true
		activation_timer.wait_time = activation_delay
		activation_timer.connect("timeout", Callable(self, "_on_activation_delay_timeout"))
		add_child(activation_timer)
	
	
	appear()  # Ensure the laser beam appears immediately
	
	set_laser_color(Color(2.5, 0, 0, 1), Color(1.5, 0, 0, 1), Color(2, 0, 0, 0.3))


func _physics_process(delta: float) -> void:
	if is_casting:
		target_position = (target_position + Vector2.RIGHT * cast_speed * delta).limit_length(max_length)
		cast_beam()


func set_is_casting(cast: bool) -> void:
	is_casting = cast
	set_physics_process(is_casting)
	beam_particles.emitting = is_casting
	casting_particles.emitting = is_casting
	if is_casting:
		appear()
	else:
		disappear()
		
		
func activate_with_delay() -> void:
	if use_delayed_activation:
		activation_timer.start()
	else:
		is_casting = true
	

func _on_activation_delay_timeout() -> void:
	is_casting = true


# Controls the emission of particles and extends the Line2D to `cast_to` or the ray's 
# collision point, whichever is closest.
func cast_beam() -> void:
	var cast_point := target_position

	force_raycast_update()
	collision_particles.emitting = is_colliding()

	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particles.global_rotation = get_collision_normal().angle()
		collision_particles.position = cast_point
		
		var collider = get_collider()
		if collider and collider.name == "Ball":
			handle_ball_collision(collider)

	fill.points[1] = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5


func appear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(fill, "width", line_width, growth_time * 2).from(0)

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(fill, "width", 0, growth_time).from_current()
	

func handle_ball_collision(ball: Node2D) -> void:
	ball = $"../Ball"
	ball.laser_kill = true

# Deactivate the laser
func deactivate() -> void:
	is_casting = false
	disappear()


func set_laser_color(color: Color, color2: Color, color3: Color) -> void:
	fill.modulate = color
	casting_particles.modulate = color2
	beam_particles.modulate = color
	collision_particles.modulate = color3
