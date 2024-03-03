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

func _ready() -> void:
	print ("Chase Speed now ", CHASE_SPEED)

# increase chase speed by n each wave
func chase_modifier() -> float:
	return float(10*Globals.wave_num)

# increment enemy health by n every other wave
func HP_modifier() -> int:
	return floor(clamp(Globals.wave_num/2, 0, Globals.wave_num/2))

# TODO: vary this by enemy type or something more complex
# increment enemy points by n every other wave
func points_modifier() -> int:
	return floor(clamp(Globals.wave_num/2, 0, Globals.wave_num/2))
