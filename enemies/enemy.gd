extends CharacterBody2D
class_name Enemy

var Death_Animation: PackedScene = preload("res://enemies/death_animation.tscn")

@onready var movement_target_position: Vector2
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var stats: Stats = $Stats
@onready var attack_timer: Timer = $AttackTimer
@onready var gun_controller: Node = $GunController
@onready var polygon_2d = $Polygon2D
@onready var attack_light: PointLight2D = $AttackLight

enum state {
	SEEKING,
	ATTACKING,
	RETURNING,
	RESTING
}

var player: CharacterBody2D
var player_dead: bool = false

var attacking: bool = false
var current_state: state = state.SEEKING
var damage: int = -1 # set via Stats instance
var explosion_sfx: Array = [
	"res://assets/musicSfx/Explosion_v2_variation_01_wav.wav",
	"res://assets/musicSfx/Explosion_v2_variation_02_wav.wav",
	"res://assets/musicSfx/Explosion_v2_wav.wav",
	"res://assets/musicSfx/Explosion_v3_variation_01_wav.wav",
	"res://assets/musicSfx/Explosion_v3_variation_02_wav.wav",
	"res://assets/musicSfx/Explosion_v3_wav.wav"
]
var splash_damage: int = 1 # TODO: vary by wave

# basic guidance: https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html
#
# need to wait for this PR that merges tilemap layers together to make a navMesh in 2d: 
# https://github.com/godotengine/godot/pull/70724
# it adds 2D navigation mesh baking with proper agent size so you can just use 
# a NavigationRegion2D and ignore the entire TileMap build-in navigation

func _ready() -> void:
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.try_again.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	
	call_deferred("actor_setup") # Make sure to not await during _ready
	player = identify_player() # TODO: Clean this up
		
	randomize() # for enemy colors
	
	damage = stats.DAMAGE
	wave_modifier()
	
func _physics_process(_delta) -> void:
	if player != null: # i.e., player isn't dead
		movement_target_position = player.global_position
		
		match current_state:
			state.SEEKING:
				# if nav_agent.is_navigation_finished(): # bugs out
				if nav_agent.is_target_reached() or not nav_agent.is_target_reachable():
					return
				
				var current_agent_position: Vector2 = global_position # enemy position
				var next_path_position: Vector2 = nav_agent.get_next_path_position()
				var new_velocity: Vector2 = next_path_position - current_agent_position
				
	#			if not player:
	#				movement_target_position = Vector2.ZERO
					
				new_velocity = new_velocity.normalized()
				new_velocity = new_velocity * stats.CHASE_SPEED
				velocity = new_velocity
				look_at(movement_target_position)
				move_and_slide()
			state.ATTACKING:
				move_and_attack()
			state.RETURNING:
				print("going back")
			state.RESTING:
				print("resting")
	else:
		player = identify_player() # TODO: Clean this up

func actor_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame
	
	# Now that the navigation map is no longer empty, set the movement target
	set_movement_target(movement_target_position)
	
func set_movement_target(movement_target: Vector2) -> void:
	nav_agent.target_position = movement_target

func move_and_attack() -> void:
	attack_timer.start()
	# not happy with the way enemies are firing
	#gun_controller.fire()

# TODO: Clean this up
func identify_player() -> CharacterBody2D:
	var first_player: CharacterBody2D
	var players: Array = get_tree().get_nodes_in_group("player")
	
	for alive_player in players:
		first_player = alive_player
		break
	
	return first_player
	
func self_destruct() -> void:
	await get_tree().create_timer(2).timeout
	# self destruct all enemies at once
	get_tree().call_group("enemy", "_on_stats_no_health")
	
	# TODO: Want this to iterate through enemies and destroy them
	# but currently just destroys all at once
	# likely need to put this in another script as this is in the instance
	# getting destroyed...
#	var enemies_alive = get_tree().get_nodes_in_group("enemy")
#	for enemy in enemies_alive:
#		stats.current_HP = 0

# enemy modifiers/wave
# HP, CHASE_SPEED set in stats
func wave_modifier() -> void:
	var scale_multiplier = float("1.%s" % (Globals.wave_num-1))
	var colors = [
		Color(0.08,0.27,0.29,1),
		Color(0.06,0.25,0.41,1),
		Color(0.31,0.18,0.38,1),
		Color(0.41,0.14,0.19,1)
	]
	
	self.scale *= scale_multiplier
	polygon_2d.modulate = colors[randi() % colors.size()]
	
# player shoots enemy
func _on_area_2d_body_entered(body) -> void:
	if "bullet" in body.name:
		stats.current_HP -= body.damage
#		print("hit ", stats.current_HP, "/", stats.MAX_HP)

# enemy dies
func _on_stats_no_health() -> void:
	var explosion = Death_Animation.instantiate()
	explosion.position = get_global_position()
	# get_tree().get_root() -- I don't think it makes a difference which is used
	get_parent().call_deferred("add_child", explosion)
	queue_free()
#	call_deferred('free')
	
	AudioManager.play_sfx(Globals.random_sfx(explosion_sfx))
	
	if not player_dead:
		SignalBus.emit_signal("update_score", 1)

# TODO: change to raycast?
func _on_attack_range_body_entered(_body) -> void:
	pass
	# I'm not happy with the way enemy shooting is working, so disabling
	# this for now
	#if body.is_in_group("player"):
	#	current_state = state.ATTACKING

func _on_path_update_timer_timeout() -> void:
	if player != null:
		set_movement_target(movement_target_position)
#		movement_target_position = Vector2.ZERO	

func _on_attack_timer_timeout() -> void:
	print("done")
	current_state = state.SEEKING

func _on_start_game() -> void:
	player_dead = false
	
func _on_game_over() -> void:
	player_dead = true
	self_destruct()

# TODO: instance stats on death_animation scene
# use stats.DAMAGE in node, then use area.damage here
func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area.is_in_group("splash_damage"):
		stats.current_HP -= splash_damage
