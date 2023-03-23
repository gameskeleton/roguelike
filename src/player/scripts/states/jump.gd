extends RkStateMachineState

func start_state():
	player_node.handle_jump(player_node.JUMP_STRENGTH)
	player_node.play_animation("jump")
	if player_node.input_velocity.x != 0:
		player_node.set_direction(int(sign(player_node.input_velocity.x)))

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_airborne_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION)
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand
	if player_node.is_on_ceiling():
		player_node.velocity.y = player_node.CEILING_KNOCKDOWN
		return player_node.fsm.state_nodes.fall
	if player_node.velocity.y > 0:
		return player_node.fsm.state_nodes.fall
