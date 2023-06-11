extends Control

@onready var high_score_num = $Panel/HighScoreVBoxContainer/HighScoreNum
@onready var score_num = $Panel/ScoreVBoxContainer/ScoreNum
@onready var try_again_button = $Panel/TryAgainButton

func ready() -> void:
	high_score_num.text = str(Globals.high_score)
	score_num.text = str(Globals.score)
	await get_tree().create_timer(2.0).timeout
	Globals.tween_appear(try_again_button)

func _on_try_again_button_pressed():
	SignalBus.emit_signal("try_again")
	queue_free()
