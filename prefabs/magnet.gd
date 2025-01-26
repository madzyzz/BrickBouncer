extends StaticBody2D

@export var magnet_strength: float = 4.0
@export var max_horizontal_speed: float = 350.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var magnetic_area = $Area2D
@onready var pull_point = $"Pull point"

var is_ball_within_area: bool = false

func _ready() -> void:
	animated_sprite.play("Static_magnet")
	animated_sprite.frame = 0

	magnetic_area.connect("body_entered", Callable(self, "_on_body_entered"))
	magnetic_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		is_ball_within_area = true  # Activate the magnet for the ball
		print("Ball entered magnet area:", name)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Ball":
		is_ball_within_area = false  # Deactivate the magnet for the ball
		print("Ball exited magnet area:", name)

func apply_magnetic_force(ball: Node2D) -> void:
	if is_ball_within_area:  # Only apply the force if the ball is within the area
		animated_sprite.play("Pull_anim")

		var magnet_x = pull_point.global_position.x
		var ball_x = ball.global_position.x
		var distance_x = magnet_x - ball_x
		var force = clamp(distance_x * magnet_strength, -max_horizontal_speed, max_horizontal_speed)

		var current_speed = ball.linear_velocity.length()
		ball.linear_velocity.x += force * 0.1
		ball.linear_velocity = ball.linear_velocity.normalized() * current_speed
	else:
		deactivate_magnet_force()  # Reset to the static animation if not active

func deactivate_magnet_force() -> void:
	animated_sprite.play("Static_magnet")
	animated_sprite.frame = 0
