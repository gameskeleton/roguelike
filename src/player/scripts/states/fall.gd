extends RkStateMachineState

func start_state():
	player_node.play_animation("jump_to_fall")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_airborne_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION)
	player_node.play_animation_transition("jump_to_fall", "fall")
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand if player_node.velocity.x == 0 else player_node.fsm.state_nodes.walk
	if player_node.input_attack_once and player_node.is_able_to_attack():
		return player_node.fsm.state_nodes.attack
