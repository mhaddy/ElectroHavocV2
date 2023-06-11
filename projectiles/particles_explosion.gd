extends GPUParticles2D

# TODO: Reduce wait time on timer from 2s to something lower to tweak
# splash damage effect

#var damage: int = 1

func _ready():
	one_shot = true

func _on_timer_timeout():
	queue_free()
