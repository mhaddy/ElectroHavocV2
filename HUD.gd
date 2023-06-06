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

func _ready():
	SignalBus.update_score.connect(_on_update_score)
	SignalBus.update_wave.connect(_on_update_wave)
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	
	message_original_position = message.global_position
	
func show_message(text):
	message.global_position = message_original_position
	message_timer.start()
	message.text = text
	message.show()
	
func _on_game_over():
	Globals.tween_appear(message)
	show_message("Game Over!")
	AudioManager.play_sfx(Globals.random_sfx(gameover_sfx))

	# TODO -- NEW HIGH SCORE SCENE, ETC.
	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(3.0).timeout
	Globals.tween_appear(start_button)

func _on_update_score(points):
	Globals.score += points
	score_label.text = str(Globals.score)
	
	if Globals.score % 10 == 0:
		Globals.tween_pulsate(score_label)
	
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
