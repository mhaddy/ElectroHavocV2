class_name power_ups
extends Area2D

func _ready() -> void:
	pass
	
func _on_timer_timeout():
	destroy_power_up()

func destroy_power_up() -> void:
	queue_free()

func apply_power_up(body: Player) -> void:
	# this needs to be implemented by the inheriting script
	pass
	
func _on_body_entered(body):
	if body is Player:
		apply_power_up(body)
		destroy_power_up()

# TODO: Not used but is being called somewhere
func _on_area_entered(area):
	pass
