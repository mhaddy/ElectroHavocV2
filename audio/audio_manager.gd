extends Node

@onready var bgm: AudioStreamPlayer = $bgm
@onready var effect_player: Node = $effect_player

func _ready() -> void:
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.try_again.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	
	bgm.stream_paused = true
	
# change music in the game in menu, boss fight, etc.
func play_music(music) -> void:
	bgm.stream = music
	bgm.play()
	
# play sfx
# the # of effect_player_{n} allows multiple sfx to be played at the same time
func play_sfx(clip) -> void:
	var n: int = effect_player.get_child_count()
	
	for i in range(n):
		var child: AudioStreamPlayer = effect_player.get_child(i)
		if !child.playing:
			child.stream = clip
			child.play()
			return

func stop_music() -> void:
	if bgm.playing:
		bgm.stream_paused = true

func _on_start_game() -> void:
	bgm.play()

func _on_game_over() -> void:
	stop_music()
