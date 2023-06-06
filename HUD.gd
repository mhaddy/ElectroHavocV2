extends CanvasLayer

@onready var message = $Message
@onready var message_timer = $MessageTimer
@onready var start_button = $StartButton
@onready var score_label = $ScoreLabel
@onready var wave_label = $WaveLabel

var message_original_position: Vector2
var gameover_sfx: Array = [
	"res://assets/musicSfx/gameOver.ogg"
]
var finish_game_sfx: Array = [
	"res://assets/musicSfx/finishGame.mp3"
]

# TODO:
#var Finish_Game_Halo: PackedScene = preload("res://halo_effect.tscn")

func _ready():
	SignalBus.update_score.connect(_on_update_score)
	SignalBus.update_wave.connect(_on_update_wave)
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.finish_game.connect(_on_finish_game)
	
	message_original_position = message.global_position
	
func show_message(text: String, fade_out: bool = true):
	message.global_position = message_original_position
	
	if fade_out:
		message_timer.start()
	
	message.text = text
	message.show()
	
func _on_game_over():
	Globals.tween_appear(message)
	show_message("Game Over!")
	AudioManager.play_sfx(Globals.random_sfx(gameover_sfx))
	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(3.0).timeout
	Globals.tween_appear(start_button)

func _on_update_score(points):
	Globals.score += points
	score_label.text = str(Globals.score)
		
	if Globals.score % 10 == 0:
		Globals.tween_pulsate(score_label)
	
	# TODO: Display this in a message queue bottom left corner of screen
	# include combos and other modifier info
	if Globals.score > Globals.high_score:
		Globals.high_score = Globals.score
		print("New high score, ", Globals.high_score)
	
func _on_update_wave(wave_num):
	Globals.tween_pulsate(wave_label)
	wave_label.text = "Wave "+str(wave_num)

func _on_message_timer_timeout():
	Globals.tween_fade_out(message, 0.5, false)

func _on_start_button_pressed():
	start_button.hide()
	SignalBus.emit_signal("start_game")
	
func _on_start_game():
	# wave updated in spawners.gd
	Globals.score = 0
	SignalBus.emit_signal("update_score", 0)
	show_message("Get Ready")

func _on_finish_game():
	AudioManager.play_sfx(Globals.random_sfx(finish_game_sfx))
	
	Globals.tween_appear(message)
	show_message("Complete!", false)

	# TODO:
	# create a high score/level complete/fan fare scene
#	var halo = Finish_Game_Halo.instantiate()
#	halo.position = message.get_global_position()
#	get_tree().get_root().add_child(halo)
	
	await get_tree().create_timer(3.0).timeout
	
	Globals.tween_appear(start_button)
