class_name power_ups
extends Area2D

# TODO: Replace the power-up properties with custom resources

# CollisionShape2D needs to be implemented by the inheriting script

func _ready() -> void:
	pass
	
func _on_timer_timeout():
	destroy_power_up()

func destroy_power_up() -> void:
	queue_free()

func apply_power_up(_body: Player) -> void:
	# this needs to be implemented by the inheriting script
	pass
	
func _on_body_entered(body):
	if body is Player:
		apply_power_up(body)
		destroy_power_up()

# BUG: Not used but is being called somewhere
func _on_area_entered(_area):
	pass
