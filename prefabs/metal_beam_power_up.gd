extends "res://Scripts/power_up.gd"

func on_collected():
	print("Metal Beam Powerup collected!")
	queue_free()  # Optionally keep this if you want the powerup to disappear after collection

