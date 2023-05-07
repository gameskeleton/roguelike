extends RkStateMachineState

func start_state():
	player_node.play_animation("crouch_walk")
	player_node.set_one_way_detector_active(true)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_floor_move(delta, player_node.CROUCH_MAX_SPEED, player_node.CROUCH_ACCELERATION, player_node.CROUCH_DECELERATION * player_node.CROUCH_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.input_pressed(player_node.input_down) and player_node.is_on_floor_one_way():
		player_node.handle_drop_through_one_way()
	if not player_node.input_pressed(player_node.input_down) and player_node.is_able_to_uncrouch():
		return player_node.fsm.state_nodes.crouch_to_stand
	if player_node.input_just_pressed(player_node.input_roll) and player_node.is_able_to_roll():
		return player_node.fsm.state_nodes.roll
	if player_node.input_velocity.x == 0.0:
		return player_node.fsm.state_nodes.crouch
	if player_node.input_velocity.x != 0.0 and player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.crouch
	if player_node.input_velocity.x == 0.0 and player_node.velocity.x != 0.0:
		return player_node.fsm.state_nodes.crouch
	if player_node.input_velocity.x == 0.0 and player_node.velocity.x == 0.0:
		return player_node.fsm.state_nodes.crouch

func finish_state():
	player_node.set_one_way_detector_active(false)
