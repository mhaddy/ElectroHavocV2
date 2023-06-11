extends GPUParticles2D

func _ready():
	one_shot = true

func _on_timer_timeout():
	queue_free()
