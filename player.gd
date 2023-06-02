extends CharacterBody2D

@export var ACCELERATION: float = 500
@export var MAX_SPEED: float = 80
@export var FRICTION: float = 500

@onready var weapon_mount_point: Marker2D = $WeaponMountPoint
@onready var gun_controller: Node = $GunController
@onready var stats: Stats = $Stats

func _ready() -> void:
	pass

func _physics_process(delta) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO: # when we're moving
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else: # when we're idle
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move_and_slide()

	look_at(get_global_mouse_position())
		
	if Input.is_action_pressed("primary_action"):
		gun_controller.fire()

# enemy collides with/damages player
func _on_area_2d_body_entered(body) -> void:
	if "enemy" in body.name:
		stats.current_HP -= body.damage
		print("enemy hit me ", stats.current_HP, "/", stats.max_HP, ", ", body.damage)

func _on_stats_no_health():
	print ("game over!")
	# TODO: explosion
	SignalBus.emit_signal("game_over")
