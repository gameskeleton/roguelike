extends RkStateMachineState

func start_state():
	player_node.play_animation("stand_to_crouch")
	player_node.set_one_way_detector_active(true)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.CROUCH_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_down.is_pressed() and player_node.input_jump.is_just_pressed() and player_node.is_on_floor_one_way():
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.is_animation_finished():
		return player_node.fsm.state_nodes.crouch

func finish_state():
	player_node.set_one_way_detector_active(false)
