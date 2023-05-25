extends Node2D

@onready var hud = $HUD

var score: int = 0

func _ready():
	pass
	# DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func new_game():
	hud.update_score(score)
	hud.show_message("Get Ready")
	
func game_over():
	hud.show_game_over()
