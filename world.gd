extends Node2D

@onready var PLAYER: PackedScene = preload("res://player/player.tscn")
@onready var player_spawn_point: Marker2D = $player/PlayerSpawnPoint
@onready var world_camera_node_path: NodePath = "/root/world/WorldCamera"

func _ready() -> void:
	SignalBus.emit_signal("start_game") # from start menu
	SignalBus.try_again.connect(_on_try_again) # after player death
	SignalBus.game_over.connect(_on_game_over)
	
	# enable for full screen
	# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
# self destruct all enemies (sequentially)
func enemy_self_destruct() -> void:	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		await get_tree().create_timer(0.5).timeout

		if not is_instance_valid(enemy):
			continue

		if enemy.has_method("_on_stats_no_health"):
			enemy._on_stats_no_health()

func _on_try_again() -> void:
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.size() == 0: # player is dead
		var player: Player = PLAYER.instantiate()
		player.global_position = player_spawn_point.global_position
		get_parent().get_node("world/player").add_child(player)
		
		var playerCamera: RemoteTransform2D = player.get_node("PlayerCamera")
		playerCamera.remote_path = world_camera_node_path

func _on_game_over() -> void:
	enemy_self_destruct()
