extends GPUParticles2D

# Reduce wait time on timer to lower splash damage effect

func _ready():
	one_shot = true

func _on_timer_timeout():
	queue_free()
