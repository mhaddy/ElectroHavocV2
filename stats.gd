extends Node
class_name Stats

signal no_health

@export var MAX_HP: int = 1 + HP_modifier() # wave difficulty
@export var DAMAGE: int = 1
@export var CHASE_SPEED: float = 100
@export var POINTS: int = 1 + points_modifier() # wave difficulty

@onready var current_HP: int = MAX_HP:
	get:
		return current_HP
	set(value):
		current_HP = value
		if current_HP <= 0:
			emit_signal("no_health")

func _ready() -> void:
	# make enemies chase 10% quicker each wave
	# Globals.wave_num-1 to make it slightly slower
	var chase_multiplier = float("1.%s" % (Globals.wave_num))
	CHASE_SPEED *= chase_multiplier

# increment enemy health by 1 every other wave
func HP_modifier() -> int:
	return floor(clamp(Globals.wave_num/2, 0, Globals.wave_num/2))

# TODO: vary this by enemy type or something more complex
# increment enemy points by 1 every other wave
func points_modifier() -> int:
	return floor(clamp(Globals.wave_num/2, 0, Globals.wave_num/2))
