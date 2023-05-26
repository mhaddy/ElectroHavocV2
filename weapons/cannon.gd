extends Node2D

@export var BULLET: PackedScene
@export var BULLET_SPEED: float = 1000
@export var FIRE_DELAY: float = 0.09

@onready var muzzle: Marker2D = $muzzle
@onready var timer: Timer = $Timer

var can_fire: bool = true

func _ready():
	timer.wait_time = FIRE_DELAY
	
func _physics_process(delta):
	pass

func fire():
	if can_fire:
		var bullet = BULLET.instantiate()
		bullet.position = muzzle.global_position
		bullet.rotation_degrees = global_rotation_degrees
		bullet.transform = muzzle.global_transform
		# apply gravity and rotate vector to the player's rotation
		bullet.linear_velocity = Vector2(BULLET_SPEED, 0).rotated(global_rotation)
		get_tree().get_root().call_deferred("add_child", bullet)
		can_fire = false
		timer.start()
		#await get_tree().create_timer(FIRE_DELAY).timeout

func _on_timer_timeout():
	can_fire = true
