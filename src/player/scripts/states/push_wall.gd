extends RkStateMachineState

func start_state():
	player_node.play_animation("push_wall")
	player_node.set_one_way_detector_active(true)
	player_node.set_push_wall_roll_detector_active(true)
	if (player_node.direction < 0.0 and not player_node.is_on_wall_passive(-1.0)) or (player_node.direction > 0.0 and not player_node.is_on_wall_passive(+1.0)):
		return player_node.fsm.state_nodes.stand if player_node.input_velocity.x == 0.0 else player_node.fsm.state_nodes.walk

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_floor_move(delta, player_node.WALK_MAX_SPEED, player_node.WALK_ACCELERATION, player_node.WALK_DECELERATION * player_node.WALK_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_down.is_down() and player_node.is_able_to_crouch():
		return player_node.fsm.state_nodes.stand_to_crouch
	if player_node.input_jump.is_pressed() and player_node.input_down.is_down() and player_node.is_on_floor_one_way():
		player_node.input_jump.consume()
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump.is_pressed() and player_node.is_able_to_jump():
		player_node.input_jump.consume()
		return player_node.fsm.state_nodes.jump
	if player_node.input_roll.is_pressed() and player_node.is_able_to_roll_when_pushing_wall():
		player_node.input_roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input_velocity.x == 0.0:
		return player_node.fsm.state_nodes.stand
	if (player_node.input_velocity.x < 0.0 and not player_node.is_on_wall_passive(-1.0)) or (player_node.input_velocity.x > 0.0 and not player_node.is_on_wall_passive(+1.0)):
		return player_node.fsm.state_nodes.walk

func finish_state():
	player_node.set_one_way_detector_active(false)
	player_node.set_push_wall_roll_detector_active(true)
