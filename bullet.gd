extends RigidBody2D

# particles
var Explosion: PackedScene = preload("res://particles_explosion.tscn")

func _on_body_entered(body):
	if !body.is_in_group("player"):
		var explosion = Explosion.instantiate()
		explosion.position = get_global_position()
		get_tree().get_root().add_child(explosion)
		queue_free()
