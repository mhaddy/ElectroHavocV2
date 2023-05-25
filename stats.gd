extends Node
class_name Stats

@export var max_HP: int = 1

@onready var current_HP: int = max_HP:
	get:
		return current_HP
	set(value):
		current_HP = value
		if current_HP <= 0:
			emit_signal("no_health")

signal no_health
