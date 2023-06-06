extends Node2D

@export var BULLET: PackedScene
@export var BULLET_SPEED: float = 1000
@export var FIRE_DELAY: float = 0.15

@onready var muzzle: Marker2D = $muzzle
@onready var timer: Timer = $Timer

var can_fire: bool = true
var weapon_sfx: Array = [
	"res://assets/musicSfx/Laser_Shot_v2_wav.wav",
	"res://assets/musicSfx/Laser_Shot_v2_variation_01_wav.wav",
	"res://assets/musicSfx/Laser_Shot_v2_variation_02_wav.wav",
	"res://assets/musicSfx/Laser_Shot_v2_variation_03_wav.wav"
]

func _ready() -> void:
	timer.wait_time = FIRE_DELAY

func fire() -> void:
	if can_fire:
		var bullet = BULLET.instantiate()
		bullet.position = muzzle.global_position
		bullet.rotation_degrees = global_rotation_degrees
		bullet.transform = muzzle.global_transform
		# apply gravity and rotate vector to the player's rotation
		bullet.linear_velocity = Vector2(BULLET_SPEED, 0).rotated(global_rotation)
		get_tree().get_root().call_deferred("add_child", bullet)
		AudioManager.play_sfx(Globals.random_sfx(weapon_sfx))
		can_fire = false
		timer.start()

func _on_timer_timeout() -> void:
	can_fire = true
