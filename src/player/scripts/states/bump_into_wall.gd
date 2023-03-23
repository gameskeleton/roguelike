extends RkStateMachineState

var _animation_initial_speed_scale := 1.0

func start_state():
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.handle_roll(player_node.direction * player_node.ROLL_BUMP_STRENGTH)
	player_node.play_animation("death_in_place")
	player_node.animation_player.speed_scale = 1.8

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.ROLL_DECELERATION)
	if player_node.is_stopped() and player_node.is_animation_finished():
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
