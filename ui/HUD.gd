extends CanvasLayer

@onready var message = $Message
@onready var message_timer = $MessageTimer
@onready var try_again_button = $TryAgainButton
@onready var score_num = $ScoreLabel/ScoreNum
@onready var high_score_num = $HighScoreLabel/HighScoreNum
@onready var wave_label = $WaveLabel

var message_original_position: Vector2
var gameover_sfx: Array = [
	"res://assets/musicSfx/gameOver.ogg"
]
var finish_game_sfx: Array = [
	"res://assets/musicSfx/finishGame.mp3"
]

var Game_Over_Modal: PackedScene = preload("res://ui/game_over_modal.tscn")
var Finish_Game_Modal: PackedScene = preload("res://ui/finish_game_modal.tscn")

func _ready() -> void:
	SignalBus.update_score.connect(_on_update_score)
	SignalBus.update_wave.connect(_on_update_wave)
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.try_again.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.finish_game.connect(_on_finish_game)
	
	message_original_position = message.global_position
	update_high_score(Globals.high_score) # from save game
	
func show_message(text: String, fade_out: bool = true) -> void:
	message.global_position = message_original_position
	
	if fade_out:
		message_timer.start()
	
	message.text = text
	message.show()
	
func _on_game_over() -> void:
	AudioManager.play_sfx(Globals.random_sfx(gameover_sfx))
	
	var game_over_modal = Game_Over_Modal.instantiate()
	game_over_modal.global_position = Globals.player_position
	get_parent().add_child(game_over_modal)
	Globals.tween_appear(game_over_modal)

func _on_update_score(points) -> void:
	Globals.score += points
	score_num.text = str(Globals.score)
		
	if Globals.score % 10 == 0:
		Globals.tween_pulsate(score_num)
	
	# TODO: Display this in a message queue bottom left corner of screen
	# include combos and other modifier info
	if Globals.score > Globals.high_score:
		update_high_score(Globals.score)

# also called when loading saved games
func update_high_score(points) -> void:
	Globals.high_score = points
	high_score_num.text = str(Globals.high_score)

func _on_update_wave(wave_num) -> void:
	Globals.tween_pulsate(wave_label)
	wave_label.text = "Wave "+str(wave_num)

func _on_message_timer_timeout() -> void:
	Globals.tween_fade_out(message, 0.5, false)

func _on_try_again_button_pressed() -> void:
	try_again_button.hide()
	SignalBus.emit_signal("try_again")
	
func _on_start_game() -> void:
	# wave updated in spawners.gd
	Globals.score = 0
	SignalBus.emit_signal("update_score", 0)
	show_message("Get Ready")

func _on_finish_game() -> void:
	AudioManager.play_sfx(Globals.random_sfx(finish_game_sfx))
	
	var finish_game_modal = Finish_Game_Modal.instantiate()
	finish_game_modal.global_position = Globals.player_position
	get_parent().add_child(finish_game_modal)
	Globals.tween_appear(finish_game_modal)

# Using Globals.player_position instead
#func _get_viewport_center() -> Vector2:
#	var viewport: Vector2 = DisplayServer.window_get_size()
#	print(viewport)
#	return Vector2(viewport.x/2, viewport.y/2)
