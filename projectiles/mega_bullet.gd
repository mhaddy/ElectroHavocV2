extends RigidBody2D

@export var damage: int = 2

# when the bullet enters a body
func _on_body_entered(body: Node):
	# as long as it isn't the player's body
	if !body.is_in_group("player"):
		var explosion = Globals.Explosion.instantiate()
		explosion.position = get_global_position()
		get_tree().get_root().add_child(explosion)
		queue_free()
