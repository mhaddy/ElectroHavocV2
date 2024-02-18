extends CanvasLayer

@onready var message = $Message
@onready var message_timer = $MessageTimer
@onready var try_again_button = $TryAgainButton
@onready var score_num = $ScoreLabel/ScoreNum
@onready var high_score_num = $HighScoreLabel/HighScoreNum
@onready var wave_label = $WaveLabel
@onready var chat_messages = $ChatQueue/ChatMessagesLabel
#@onready var health_bar = $HealthLabel/HealthBackground/HealthBar
@onready var HEALTH_BAR: PackedScene = preload("res://ui/health_bar.tscn")
@onready var health_background = $HealthLabel/HealthBackground

var message_original_position: Vector2
var gameover_sfx: Array = [
	"res://assets/musicSfx/gameOver.ogg"
]
var finish_game_sfx: Array = [
	"res://assets/musicSfx/finishGame.mp3"
]

var Game_Over_Modal: PackedScene = preload("res://ui/game_over_modal.tscn")
var Finish_Game_Modal: PackedScene = preload("res://ui/finish_game_modal.tscn")

var chat_queue: Array = []

func _ready() -> void:
	SignalBus.update_score.connect(_on_update_score)
	SignalBus.update_wave.connect(_on_update_wave)
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.try_again.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	SignalBus.finish_game.connect(_on_finish_game)
	SignalBus.chat_queue.connect(_on_message_received)
	SignalBus.update_health.connect(_on_update_health)
	
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
	var points_text = " points"
	Globals.score += int(points)
	score_num.text = str(Globals.score)
	
	if points == 1:
		points_text = " point"
	elif points > 1:
		points_text = " points"

	if points > 0:
		SignalBus.emit_signal("chat_queue", "+"+str(points)+points_text)
		
	if Globals.score % 10 == 0:
		Globals.tween_pulsate(score_num)

	if Globals.score > Globals.high_score:
		update_high_score(Globals.score)

# also called when loading saved games
func update_high_score(points) -> void:
	Globals.high_score = points
	high_score_num.text = str(Globals.high_score)
	SignalBus.emit_signal("chat_queue", "NEW HIGH SCORE +"+str(points)+" points")
	
func clear_chat_queue() -> void:
	chat_messages.text = ""

# create 1 health bar for each HP the player has at start
func add_health_bars() -> void:
	for i in range(0,Globals.player_hud_health):
		var bar_count = i+1
		var health_bar = HEALTH_BAR.instantiate()
		health_background.add_child(health_bar)
		health_bar.global_position = health_background.global_position + Vector2(bar_count*22,13) # Vector2(i*35, 15)
		#var duplicated_health_bar = health_bar.duplicate()
		#health_background.add_child(duplicated_health_bar)
		#duplicated_health_bar.position = health_bar.global_position + Vector2(i*25, 0)

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
	clear_chat_queue()
	SignalBus.emit_signal("update_score", 0)
	show_message("Get Ready")
	SignalBus.emit_signal("chat_queue", "NEW GAME!")
	
	add_health_bars()

func _on_finish_game() -> void:
	AudioManager.play_sfx(Globals.random_sfx(finish_game_sfx))
	
	var finish_game_modal = Finish_Game_Modal.instantiate()
	finish_game_modal.global_position = Globals.player_position
	get_parent().add_child(finish_game_modal)
	Globals.tween_appear(finish_game_modal)
	
	SignalBus.emit_signal("chat_queue", "VICTORY!")
	
func _on_message_received(chat_message) -> void:
	chat_queue.append(chat_message)
	
	if chat_queue.size() > 0:
		var next_message = chat_queue[0]
		chat_queue.pop_front()
		chat_messages.text += "\n" + next_message
	else:
		chat_messages.text = "Test Message"

func _on_update_health(damage) -> void:
	var health_bar_count: int = health_background.get_child_count()
		
	if health_bar_count > 0:
		var last_child: Node2D = health_background.get_child(health_bar_count - 1)
		
		if damage < 0:
			last_child.queue_free()
		else:
			# TODO: I don't currently have a health power-up
			# So I need to create one!
			# this is future-proofing code...
			var health_bar = HEALTH_BAR.instantiate()
			health_background.add_child(health_bar)
			health_bar.position = health_background.global_position + Vector2(health_bar_count*25, 0)


# Using Globals.player_position instead
#func _get_viewport_center() -> Vector2:
#	var viewport: Vector2 = DisplayServer.window_get_size()
#	print(viewport)
#	return Vector2(viewport.x/2, viewport.y/2)
