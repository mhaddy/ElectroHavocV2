extends CharacterBody2D

@export var CHASE_DELAY: float = 75
@export var CHASE_SPEED: float = 100

@onready var player: CharacterBody2D = $"../../player"
@onready var movement_target_position: Vector2 = player.global_position
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var motion: Vector2 = Vector2()

# basic guidance: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html
func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	
	# Make sure to not await during _ready
	call_deferred("actor_setup")

func _physics_process(delta):
	if nav_agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * CHASE_SPEED
		
	velocity = new_velocity
	move_and_slide()

# this code works just as well as the code above
# so clearly something isn't working with paths...
#	var player_location = player.global_position
#	var current_location = global_position
#	var next_location = nav_agent.get_next_path_position()
#	var new_velocity = (next_location - current_location).normalized() * CHASE_SPEED
#
#	update_target_location(player_location)
#	velocity = velocity.move_toward(new_velocity, 0.25)
#	move_and_slide()
	
	
# 	old code that just dumb follows player
#	var Player = player
#
#	position += (Player.position - position)/CHASE_DELAY
#	look_at(Player.position)
#
#	move_and_collide(motion)

#func update_path(target_position):
#	path = nav_agent

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	nav_agent.target_position = movement_target

func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		queue_free()

func _on_timer_timeout():
#	print("looking for player")
	set_movement_target(player.global_position)
