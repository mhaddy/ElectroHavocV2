extends CharacterBody2D
class_name Enemy

#@export var CHASE_DELAY: float = 75
@export var CHASE_SPEED: float = 100

@onready var player: CharacterBody2D = $"../../player"
@onready var movement_target_position: Vector2 = player.global_position
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var stats: Stats = $Stats
@onready var attack_timer: Timer = $AttackTimer
@onready var gun_controller: Node = $GunController
@onready var attack_light: PointLight2D = $AttackLight
# not currently working:
# https://www.gotut.net/tweens-in-godot-4/
# @onready var tween: Tween = get_tree().create_tween()

enum state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING
}

var attacking: bool = false
var current_state: state = state.SEEKING

# basic guidance: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html
#
# need to wait for this PR that merges tilemap layers together to make a navMesh in 2d: 
# https://github.com/godotengine/godot/pull/70724
# it adds 2D navigation mesh baking with proper agent size so you can just use 
# a NavigationRegion2D and ignore the entire TileMap build-in navigation

func _ready():
	# Make sure to not await during _ready
	call_deferred("actor_setup")

func _physics_process(delta):
	match current_state:
		state.SEEKING:
#			tween = create_tween()
#			tween.tween_property(attack_light, "modulate", Color.GREEN, 1)
			
			# if nav_agent.is_navigation_finished(): # bugs out
			if nav_agent.is_target_reached() or not nav_agent.is_target_reachable():
				return
			
			var current_agent_position: Vector2 = global_position # enemy position
			var next_path_position: Vector2 = nav_agent.get_next_path_position()
			var new_velocity: Vector2 = next_path_position - current_agent_position
			
			new_velocity = new_velocity.normalized()
			new_velocity = new_velocity * CHASE_SPEED
			velocity = new_velocity
			look_at(player.position)
			move_and_slide()
		state.ATTACKING:
			move_and_attack()
#			tween = create_tween()
#			tween.tween_property(attack_light, "modulate", Color.RED, 1)

		state.RETURNING:
			print("going back")
		state.RESTING:
			print("resting")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	nav_agent.target_position = movement_target

func move_and_attack():
	attack_timer.start()
	gun_controller.fire()

func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		stats.current_HP -= body.damage
		print("hit ", stats.current_HP, "/", stats.max_HP)
#		queue_free()

func _on_stats_no_health():
	queue_free()
	# TODO: death animation

# TODO: change to raycast?
func _on_attack_range_body_entered(body):
	if body == player:
		current_state = state.ATTACKING

func _on_path_update_timer_timeout():
#	print("looking for player")
	set_movement_target(player.global_position)

func _on_attack_timer_timeout():
	current_state = state.SEEKING