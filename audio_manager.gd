extends Node

@onready var bgm: AudioStreamPlayer = $bgm
@onready var effect_player: Node = $effect_player

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
