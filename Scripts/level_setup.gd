extends Node

# Number of starting lives
var amount_of_lives: int = 3

# Paths to nodes and assets
@onready var bouncer = $Bouncer  # Reference to the bouncer
@onready var health_sprite = $HeartsSystem3Lifes  # Reference to the health sprite
@onready var ball = $Ball


func _ready() -> void:
	reset_ball()

	# Initialize the health sprite
	update_health_sprite()

func lose_life() -> void:
	amount_of_lives -= 1
	update_health_sprite()

	if amount_of_lives <= 0:
		game_over()
	else:
		reset_ball()

func reset_ball() -> void:
	# Reset bouncer position
	bouncer.global_position = Vector2(400, 600)  # Example position, adjust as needed
	bouncer.is_ball_shot = false

	# Reset ball state
	ball.global_position = bouncer.global_position + Vector2(0, 10)
	ball.is_shot = false
	ball.is_locked = true
	ball.sleeping = true

	# Reset dotted line visibility
	bouncer.dotted_line.visible = true


func game_over() -> void:
	print("pull up pop-up screen")
	ball.queue_free()
	bouncer.queue_free()

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
