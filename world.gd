extends Node2D

@onready var Player: PackedScene = preload("res://player.tscn")
@onready var player_spawn_point: Marker2D = $player/PlayerSpawnPoint
@onready var world_camera_node_path: NodePath = "/root/world/WorldCamera"

func _ready() -> void:
	SignalBus.emit_signal("start_game") # from start menu
	SignalBus.try_again.connect(_on_try_again) # after player death
	
	# enable for full screen
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_try_again() -> void:
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.size() == 0: # player is dead
		var player: Player = Player.instantiate()
		player.global_position = player_spawn_point.global_position
		get_parent().get_node("world").add_child(player)
		
		var playerCamera: RemoteTransform2D = player.get_node("PlayerCamera")
		playerCamera.remote_path = world_camera_node_path

