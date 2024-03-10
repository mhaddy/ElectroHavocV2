extends Node2D

@export var ENEMY: PackedScene

@onready var timer: Timer = $Timer
@onready var waves: Node = $Waves
@onready var spawn_points: Node = $SpawnPoints
@onready var power_up_spawn_timer: Timer = $PowerUpSpawnTimer

var all_waves: Array
var current_wave: Wave
var current_wave_index: int = -1
var all_spawn_points: Array
var player_dead: bool = false

var enemies_remaining_to_spawn: int
var enemies_killed_this_wave: int

var all_power_ups: Array = [
	#preload("res://powerups/shield_power_up.tscn"),
	preload("res://powerups/mega_fire_power_up.tscn")
]
var power_ups_spawned_this_wave: int = 0

func _ready() -> void:
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.try_again.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	
	randomize()
	
	all_waves = waves.get_children()
	all_spawn_points = spawn_points.get_children()

func start_next_wave() -> void:
	enemies_killed_this_wave = 0
	current_wave_index += 1 # advance the index
	power_ups_spawned_this_wave = 0

	if current_wave_index < all_waves.size():
		Globals.wave_num = current_wave_index+1 # visual display
		SignalBus.emit_signal("update_wave", Globals.wave_num)
		SignalBus.emit_signal("chat_queue", "> Prepare for Wave "+str(Globals.wave_num))
		
		current_wave = all_waves[current_wave_index]
		
		enemies_remaining_to_spawn = current_wave.NUM_ENEMIES
		timer.wait_time = current_wave.SEC_BETWEEN_SPAWNS
		timer.start()
		
		if current_wave_index > 0: # don't need power-ups on first wave
			power_up_spawn_timer.wait_time = pick_power_up_spawn_time(current_wave)
			power_up_spawn_timer.start()
	else:
		SignalBus.emit_signal("finish_game")
	
func connect_to_enemy_signals(enemy: Enemy) -> void:
	var stats: Stats = enemy.get_node("Stats")
	stats.no_health.connect(_on_no_health)
	
func spawn() -> void:
	var spawn_point: int = pick_spawn_point()
	
	var enemy: Enemy = ENEMY.instantiate()
	connect_to_enemy_signals(enemy)
	
	# add enemy to random spawn point
	enemy.global_position = all_spawn_points[spawn_point].global_position
#	var enemy_root = get_parent().find_child("enemies")
#	enemy_root.add_child(enemy)
	get_parent().add_child(enemy)
	enemies_remaining_to_spawn -= 1

func pick_spawn_point() -> int:
	return randi_range(0, all_spawn_points.size()-1)

func pick_power_up_spawn_time(current_wave: Wave) -> int:
	return randi_range(current_wave.MIN_POWER_UP_SPAWN_TIME, current_wave.MAX_POWER_UP_SPAWN_TIME)
	
func spawn_power_ups(current_wave_index: int) -> void:
	var spawn_point: int = pick_spawn_point()
	var power_up_preload: PackedScene = all_power_ups[randi() % all_power_ups.size()]
	var power_up: power_ups = power_up_preload.instantiate()
	
	add_child(power_up)
	power_up.global_position = all_spawn_points[spawn_point].global_position
	
	power_ups_spawned_this_wave += 1
	
func _on_no_health() -> void:
	enemies_killed_this_wave += 1

func _on_timer_timeout() -> void:
	#print(enemies_killed_this_wave, " / ", enemies_remaining_to_spawn, " / ", current_wave.NUM_ENEMIES)
	if not player_dead:
		if enemies_remaining_to_spawn:
			spawn()
		else:
			if enemies_killed_this_wave >= current_wave.NUM_ENEMIES:
				start_next_wave()

func _on_start_game() -> void:
	current_wave_index = -1
	player_dead = false
	start_next_wave()

func _on_game_over() -> void:
	player_dead = true

func _on_power_up_spawn_timer_timeout():
	if power_ups_spawned_this_wave < current_wave.MAX_POWER_UPS:
		power_up_spawn_timer.wait_time = pick_power_up_spawn_time(current_wave)
		spawn_power_ups(current_wave_index)
