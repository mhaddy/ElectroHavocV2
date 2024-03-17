extends CharacterBody2D
class_name Enemy

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var stats: Stats = $Stats
@onready var attack_timer: Timer = $AttackTimer
@onready var gun_controller: Node = $GunController
@onready var polygon_2d = $Polygon2D
@onready var attack_light: PointLight2D = $AttackLight
@onready var points_label = $PointsLabel
@onready var collision_shape_for_world = $CollisionShapeForWorld

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
var can_splash_damage: bool = true
var splash_damage_delay: float = 0.25
var splash_damage_points: int = 2
var points: int = 1

func _ready() -> void:
	SignalBus.start_game.connect(_on_start_game)
	SignalBus.try_again.connect(_on_start_game)
	SignalBus.game_over.connect(_on_game_over)
	
	call_deferred("actor_setup") # Make sure to not await during _ready
	player = identify_player() # TODO: Clean this up
		
	randomize() # for enemy colors
	
	damage = stats.DAMAGE
	points = stats.POINTS
	wave_modifier()
	
func _physics_process(_delta) -> void:
	if player != null: # i.e., player isn't dead
		nav_agent.target_position = player.global_position
		
		match current_state:
			state.SEEKING:
				# TODO: I don't think I need these?
				#  or nav_agent.is_target_reached() or not nav_agent.is_target_reachable()
				if nav_agent.is_navigation_finished():
					return
				
				var current_agent_position: Vector2 = global_position # enemy position
				var next_path_position: Vector2 = nav_agent.get_next_path_position()
				var new_velocity: Vector2 = next_path_position - current_agent_position
				
				new_velocity = new_velocity.normalized()
				new_velocity *= stats.CHASE_SPEED
				velocity = new_velocity
				look_at(player.global_position)
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
	
	self.scale *= scale_multiplier # size the polygon
	collision_shape_for_world.scale *= scale_multiplier # size the hitbox
	polygon_2d.modulate = colors[randi() % colors.size()]
	
# player shoots enemy
func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("bullet"):
		stats.current_HP -= body.damage
#		print("hit ", stats.current_HP, "/", stats.MAX_HP)

# enemy dies
func _on_stats_no_health() -> void:
	var explosion = Globals.Enemy_Death_Animation.instantiate()
	explosion.global_position = get_global_position()
	get_parent().call_deferred("add_child", explosion)
	queue_free()
	
	AudioManager.play_sfx(Globals.random_sfx(explosion_sfx))
	
	if player_dead == false:
		SignalBus.emit_signal("update_score", points)

# TODO: change to raycast?
func _on_attack_range_body_entered(_body) -> void:
	pass
	# I'm not happy with the way enemy shooting is working, so disabling
	# this for now
	#if body.is_in_group("player"):
	#	current_state = state.ATTACKING

func _on_attack_timer_timeout() -> void:
	print("done")
	current_state = state.SEEKING

func _on_start_game() -> void:
	player_dead = false
	
func _on_game_over() -> void:
	player_dead = true

# TODO: instance stats on death_animation scene
# use stats.DAMAGE in node, then use area.damage here
func _on_area_2d_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if not player_dead:
		if area.is_in_group("splash_damage"):
			if can_splash_damage:
				stats.current_HP -= splash_damage
				
				SignalBus.emit_signal("update_score", splash_damage_points)
				SignalBus.emit_signal("chat_queue", "Splash damage bonus!")
				
				# limit damage applied by enemy explosion
				can_splash_damage = false
				await get_tree().create_timer(splash_damage_delay).timeout
				can_splash_damage = true
