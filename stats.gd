extends Node
class_name Stats

signal no_health

@export var MAX_HP: int = 1 + HP_modifier()
@export var DAMAGE: int = 1
@export var CHASE_SPEED: float = 100 + chase_modifier()
@export var POINTS: int = 1 + points_modifier()

@onready var current_HP: int = MAX_HP:
	get:
		return current_HP
	set(value):
		current_HP = value
		if current_HP <= 0:
			emit_signal("no_health")

# increase chase speed by n each wave
func chase_modifier() -> float:
	var min_chase_speed: float = 100
	var max_chase_speed: float = float(10*Globals.wave_num)
	var weight_factor: float = 0.8
	var rand_value: float = randf()
	var speed: float
	
	# Apply the weight to bias the random number
	if rand_value < weight_factor:
		# 80% chance to get a number closer to max_chase_speed
		speed = randf_range(max_chase_speed - 0.2 * max_chase_speed, max_chase_speed)
	else:
		# 20% chance to get a number in the full range
		speed = randf_range(min_chase_speed, max_chase_speed)

	return ceil(speed)
	
# increment enemy health by n every other wave
func HP_modifier() -> int:
	return floor(clamp(Globals.wave_num/2, 0, Globals.wave_num/2))

# TODO: vary this by enemy type or something more complex
# increment enemy points by n every other wave
func points_modifier() -> int:
	return floor(clamp(Globals.wave_num/2, 0, Globals.wave_num/2))
