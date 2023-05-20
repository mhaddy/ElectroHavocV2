extends Node2D

@export var BULLET: PackedScene
@export var BULLET_SPEED: float = 500
@export var FIRE_RATE: float = 0.09

@onready var muzzle = $muzzle
@onready var timer = $Timer

var can_fire: bool = true

func _ready():
	timer.wait_time = FIRE_RATE
	
func _physics_process(delta):
	pass

func fire():
	if can_fire:
		var bullet = BULLET.instantiate()
		bullet.position = muzzle.global_position
		bullet.rotation_degrees = global_rotation_degrees
		# apply gravity and rotate vector to the player's rotation
		bullet.linear_velocity = Vector2(BULLET_SPEED, 0).rotated(global_rotation)
		get_tree().get_root().call_deferred("add_child", bullet)
		can_fire = false
		timer.start()
		#await get_tree().create_timer(FIRE_RATE).timeout

func _on_timer_timeout():
	can_fire = true
