extends RkStateMachineState

func start_state():
	player_node.set_one_way_detector_active(true)
	if player_node.input_velocity.x != 0.0 and player_node.has_invert_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.turn_around

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.WALK_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_pressed(player_node.input_down) and player_node.input_just_pressed(player_node.input_jump) and player_node.is_on_floor_one_way():
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.is_able_to_jump():
		return player_node.fsm.state_nodes.jump
	if player_node.input_just_pressed(player_node.input_roll) and player_node.is_able_to_roll():
		return player_node.fsm.state_nodes.roll
	if player_node.input_just_pressed(player_node.input_attack) and player_node.is_able_to_attack():
		return player_node.fsm.state_nodes.attack
	if player_node.has_invert_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.turn_around
	if player_node.input_velocity.x != 0.0:
		return player_node.fsm.state_nodes.walk
	if player_node.velocity.x == 0.0:
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.set_one_way_detector_active(false)
