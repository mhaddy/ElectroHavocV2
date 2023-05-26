extends Node2D

@onready var hud = $HUD

var score: int = 0

func _ready() -> void:
	pass
	# enable for full screen
	# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func new_game() -> void:
	hud.update_score(score)
	hud.show_message("Get Ready")
	
func game_over() -> void:
	hud.show_game_over()
