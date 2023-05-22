extends Node2D

@export var ENEMY: PackedScene

@onready var timer = $Timer
@onready var waves = $Waves

var all_waves: Array
var current_wave: Wave
var current_wave_num: int = -1

var enemies_remaining_to_spawn: int
var enemies_killed_this_wave: int

func _ready():
	all_waves = waves.get_children()
	start_next_wave()

func start_next_wave():
	enemies_killed_this_wave = 0
	current_wave_num += 1
	
	if current_wave_num < all_waves.size():
		current_wave = all_waves[current_wave_num]
		
		enemies_remaining_to_spawn = current_wave.NUM_ENEMIES
		timer.wait_time = current_wave.SEC_BETWEEN_SPAWNS
		timer.start()
	
func connect_to_enemy_signals(enemy: Enemy):
#	clock.time_passed.connect(_on_time_passed)
	var stats: Stats = enemy.get_node("Stats")
	stats.no_health.connect(_on_no_health)
	
func spawn():
	var enemy = ENEMY.instantiate()
	connect_to_enemy_signals(enemy)
	var enemy_root = get_parent().find_child("enemies")
	
	# add enemy to spawn point
	# TODO: randomize, add more spawners
	enemy.position = global_position
	enemy_root.add_child(enemy)
	enemies_remaining_to_spawn -= 1
		
func _on_no_health():
	enemies_killed_this_wave += 1
	print("detect")

func _on_timer_timeout():
	if enemies_remaining_to_spawn:
		spawn()
	else:
		if enemies_killed_this_wave == current_wave.NUM_ENEMIES:
			start_next_wave()
