extends Node2D

@export var ENEMY: PackedScene

@onready var timer: Timer = $Timer
@onready var waves: Node = $Waves
@onready var spawn_points: Node = $SpawnPoints

var all_waves: Array
var current_wave: Wave
var current_wave_num: int = -1
var all_spawn_points: Array

var enemies_remaining_to_spawn: int
var enemies_killed_this_wave: int
#@onready var stats: Stats = AgentStats # access global, auto-loaded singleton

func _ready() -> void:
	SignalBus.start_game.connect(_on_start_game)
	
	randomize()
	
	all_waves = waves.get_children()
	all_spawn_points = spawn_points.get_children()

func start_next_wave() -> void:
	enemies_killed_this_wave = 0
	current_wave_num += 1
	# increment counter here because we're visually displaying it
	# not iterating an array
	SignalBus.emit_signal("update_wave", current_wave_num+1)
	
	if current_wave_num < all_waves.size(): # temp
		current_wave = all_waves[current_wave_num]
		
		enemies_remaining_to_spawn = current_wave.NUM_ENEMIES
		timer.wait_time = current_wave.SEC_BETWEEN_SPAWNS
		timer.start()
	
func connect_to_enemy_signals(enemy: Enemy) -> void:
#	clock.time_passed.connect(_on_time_passed)
	var stats: Stats = enemy.get_node("Stats")
	stats.no_health.connect(_on_no_health)
	
func spawn() -> void:
	var spawn_point: int = pick_spawn_point()
	
	var enemy = ENEMY.instantiate()
	connect_to_enemy_signals(enemy)
	var enemy_root = get_parent().find_child("enemies")
	
	# add enemy to random spawn point
	enemy.position = all_spawn_points[spawn_point].global_position
	enemy_root.add_child(enemy)
	enemies_remaining_to_spawn -= 1

func pick_spawn_point() -> int:
	return randi_range(0, all_spawn_points.size()-1)

func _on_no_health() -> void:
	enemies_killed_this_wave += 1
	print("detect")

func _on_timer_timeout() -> void:
	if enemies_remaining_to_spawn:
		spawn()
	else:
		if enemies_killed_this_wave == current_wave.NUM_ENEMIES:
			start_next_wave()

func _on_start_game() -> void:
	start_next_wave()
