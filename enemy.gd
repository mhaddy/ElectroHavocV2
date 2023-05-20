extends CharacterBody2D

@export var CHASE_DELAY = 75

@onready var player = $"../../player"

var motion: Vector2 = Vector2()

func _physics_process(delta):
	var Player = player
	
	position += (Player.position - position)/CHASE_DELAY
	look_at(Player.position)
	
	move_and_collide(motion)

func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		queue_free()
