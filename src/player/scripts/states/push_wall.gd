extends RkStateMachineState

func start_state():
	player_node.play_animation("push_wall")
	player_node.set_one_way_detector_active(true)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_floor_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION * player_node.RUN_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_pressed(player_node.input_down) and player_node.is_able_to_crouch():
		return player_node.fsm.state_nodes.stand_to_crouch
	if player_node.input_pressed(player_node.input_down) and player_node.input_just_pressed(player_node.input_jump) and player_node.is_on_floor_one_way():
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.is_able_to_jump():
		return player_node.fsm.state_nodes.jump
	if player_node.input_velocity.x == 0.0 or not player_node.has_same_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.set_one_way_detector_active(false)
