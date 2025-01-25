extends Node

# Number of starting lives
var amount_of_lives: int = 3

# Timer-related variables
@export var is_timer_level: bool = false  # Whether this is a timer-based level
@export var timer_duration: float = 60.0  # Duration of the timer in seconds
var remaining_time: float = 0.0
var timer_active: bool = false
var timer_paused: bool = true  # Start with the timer paused

# Paths to nodes and assets
@onready var bouncer = $Bouncer
@onready var health_sprite = $HeartsSystem3Lifes
@onready var ball = $Ball
@onready var timer_label = null

func _ready() -> void:
	reset_ball()
	update_health_sprite()

	# Initialize timer logic only if the level uses a timer
	if is_timer_level:
		remaining_time = timer_duration  # Ensure remaining_time starts at timer_duration
		timer_label = get_node_or_null("TimerLabel")  # Safely fetch the TimerLabel node
		if timer_label:
			update_timer_label()

	# Connect the bouncer's ball_shot signal to handle timer behavior
	bouncer.connect("ball_shot", Callable(self, "_on_ball_shot"))

func lose_life() -> void:
	amount_of_lives -= 1
	update_health_sprite()

	if amount_of_lives <= 0:
		game_over()
	else:
		reset_ball()
		for child in $PowerupsHolder.get_children():
			child.queue_free()

func reset_ball() -> void:
	$GlassStorage.clear_powerups()
	bouncer.global_position = Vector2(360, 600)
	bouncer.is_ball_shot = false

	ball.global_position = bouncer.global_position + Vector2(0, 10)
	ball.is_shot = false
	ball.is_locked = true
	ball.sleeping = true

	bouncer.dotted_line.visible = true

	# Reset the timer if it's a timer level
	if is_timer_level:
		timer_active = false

func game_over() -> void:
	$GlassStorage.clear_powerups()
	ball.queue_free()
	bouncer.queue_free()
	$Bricks_in_level.hide()
	$PowerupsHolder.hide()
	$Game_lost_screen.show()

	# Pause the timer if it's a timer level
	if is_timer_level:
		timer_active = false

func update_health_sprite() -> void:
	match amount_of_lives:
		3:
			health_sprite.texture = preload("res://prefabs/HeartsSystem_3lifes.atlastex")
		2:
			health_sprite.texture = preload("res://prefabs/HeartsSystem_2lifes.atlastex")
		1:
			health_sprite.texture = preload("res://prefabs/HeartsSystem_1lifes.atlastex")
		0:
			health_sprite.texture = preload("res://prefabs/HeartsSystem_0lifes.atlastex")

func _process(delta: float) -> void:
	# Handle timer countdown
	if is_timer_level and timer_active and not timer_paused:
		remaining_time -= delta
		if remaining_time <= 0:
			remaining_time = 0
			timer_active = false
			game_over()
		update_timer_label()

func update_timer_label() -> void:
	# Ensure the timer_label exists before updating
	if not timer_label:
		return  # Exit if the TimerLabel is not in the scene

	# Update the timer label to show the remaining time in MM:SS format
	var minutes = int(float(remaining_time) / 60)
	var seconds = int(remaining_time) % 60

	# Format minutes and seconds to always show two digits
	var minutes_str = "0" + str(minutes) if minutes < 10 else str(minutes)
	var seconds_str = "0" + str(seconds) if seconds < 10 else str(seconds)

	# Combine into MM:SS format
	timer_label.text = minutes_str + ":" + seconds_str

# Signal handler to start the timer when the ball is shot
func _on_ball_shot() -> void:
	if is_timer_level:
		timer_active = true
		timer_paused = false  # Resume the timer
