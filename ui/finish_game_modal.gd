extends Control

@onready var high_score_num = $Panel/HighScoreNum
@onready var score_num = $Panel/ScoreNum
@onready var try_again_button = $Panel/TryAgainButton
@onready var halo_effect = $HaloEffect
@onready var panel = $Panel

func _ready() -> void:
	high_score_num.text = str(Globals.high_score)
	score_num.text = str(Globals.score)
	
	Globals.tween_fade_in(try_again_button, 2.0)
	try_again_button.grab_focus()

	# center effect on the panel
	halo_effect.global_position = get_global_position()
	
func _on_try_again_button_pressed():
	SignalBus.emit_signal("try_again")
	queue_free()
