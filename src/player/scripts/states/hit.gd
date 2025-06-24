extends RkStateMachineState

@export_group("Nodes")
@export var hit_audio_stream_player: AudioStreamPlayer

func start_state():
	var damage_direction := 1.0
	if player_node.life_points_system.last_damage_source is Node2D:
		damage_direction = 1.0 if player_node.life_points_system.last_damage_source.global_position.x < player_node.global_position.x else -1.0
	player_node.velocity = Vector2(damage_direction * player_node.HIT_IMPULSE.x, player_node.HIT_IMPULSE.y)
	player_node.life_points_system.invincible += 1
	player_node.play_animation("hit")
	player_node.play_sound_effect(hit_audio_stream_player, 0.0, 0.95, 1.05)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.WALK_DECELERATION)
	if player_node.is_animation_finished():
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.life_points_system.invincible -= 1
	player_node.life_points_system.set_invincibility_delay(player_node.HIT_INVINCIBILITY_DELAY)
