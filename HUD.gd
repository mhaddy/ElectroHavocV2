extends CanvasLayer

@onready var message = $Message
@onready var message_timer = $MessageTimer
@onready var start_button = $StartButton
@onready var score_label = $ScoreLabel
@onready var wave_label = $WaveLabel

var score: int = 0

func _ready():
	SignalBus.update_score.connect(_on_update_score)
	SignalBus.update_wave.connect(_on_update_wave)
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	
func show_message(text):
	message_timer.start()
	message.text = text
	message.show()
	
func _on_game_over():
	print("received game over")
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await message_timer.timeout

	message.text = "Stay alive! LMB to shoot."
	message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	start_button.show()

func _on_update_score(points):
	score += points
	score_label.text = str(score)
	
	if score % 10 == 0:
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
	score = 0
	show_message("Get Ready")
