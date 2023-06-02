extends Node
class_name Stats

@export var max_HP: int = 1
@export var damage: int = 1

@onready var current_HP: int = max_HP:
	get:
		return current_HP
	set(value):
		current_HP = value
		if current_HP <= 0:
			emit_signal("no_health")

# not currently used...
#@onready var current_damage: int = damage:
#	get:
#		return current_damage
#	set(value):
#		current_damage = value
#		if current_damage <= 0:
#			print("level up damage")

signal no_health
