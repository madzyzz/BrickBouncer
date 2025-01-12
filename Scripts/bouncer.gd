extends CharacterBody2D

var max_speed = 500.0  
var bouncer_y_position: float
var snap_threshold = 5.0

@onready var ball_scene = preload("res://prefabs/ball.tscn")
var ball
var is_ball_shot = false

func _ready() -> void:
	bouncer_y_position = global_position.y

	# Add and position the ball
	ball = ball_scene.instantiate()
	get_parent().call_deferred("add_child", ball)
	ball.global_position = global_position + Vector2(0, 10)

func _physics_process(_delta: float) -> void:
	# Lock the bouncer in place if the ball is not shot
	if not is_ball_shot:
		velocity.x = 0
		move_and_slide()
		position.y = bouncer_y_position
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
		ball.shoot_ball(event.position)
		is_ball_shot = true
