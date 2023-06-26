extends power_ups

@export var power_up_time: float = 5.0

func apply_power_up(body: Player) -> void:
	body.apply_power_up(body.power_up.SHIELD, power_up_time)
