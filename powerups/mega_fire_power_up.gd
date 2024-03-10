extends power_ups

@export var power_up_time: float = 7.0

func apply_power_up(body: Player) -> void:
	body.apply_power_up(body.power_up.MEGA_FIRE, power_up_time)
