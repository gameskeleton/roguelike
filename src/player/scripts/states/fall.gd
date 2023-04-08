extends RkStateMachineState

func start_state():
	player_node.play_animation("jump_to_fall")
	player_node.set_wall_hang_detector_active(true)
	player_node.set_wall_slide_raycast_active(true)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_airborne_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION)
	player_node.play_animation_transition("jump_to_fall", "fall")
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand if player_node.velocity.x == 0.0 else player_node.fsm.state_nodes.walk
	if player_node.input_just_pressed(player_node.input_attack) and player_node.is_able_to_attack():
		return player_node.fsm.state_nodes.attack
	if player_node.is_able_to_wall_hang():
		return player_node.fsm.state_nodes.wall_hang
	if player_node.has_same_direction(player_node.input_velocity.x, player_node.direction) and player_node.is_able_to_wall_slide():
		return player_node.fsm.state_nodes.wall_slide

func finish_state():
	player_node.set_wall_hang_detector_active(false)
	player_node.set_wall_slide_raycast_active(false)
