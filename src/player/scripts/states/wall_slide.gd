extends RkStateMachineState

func start_state():
	player_node.velocity = Vector2(player_node.direction, minf(player_node.velocity.y, player_node.WALL_SLIDE_ENTER_MAX_VERTICAL_VELOCITY))
	player_node.play_animation("wall_slide")
	player_node.set_wall_hang_detector_active(true)
	player_node.set_wall_slide_raycast_active(true)

func process_state(delta: float):
	player_node.velocity.x = player_node.direction
	player_node.handle_gravity(delta, player_node.WALL_SLIDE_GRAVITY_MAX_SPEED, player_node.WALL_SLIDE_GRAVITY_ACCELERATION)
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand
	if not player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.fall
	if player_node.is_able_to_wall_hang():
		return player_node.fsm.state_nodes.wall_hang
	if player_node.input_just_pressed(player_node.input_jump) and player_node.is_able_to_jump():
		player_node.velocity.x = player_node.direction * player_node.WALL_SLIDE_JUMP_EXPULSE_STRENGTH
		return player_node.fsm.state_nodes.jump

func finish_state():
	if player_node.fsm.next_state_node == player_node.fsm.state_nodes.fall:
		player_node.set_direction(-player_node.direction)
	if player_node.fsm.next_state_node == player_node.fsm.state_nodes.jump:
		player_node.set_direction(-player_node.direction)
	if player_node.fsm.next_state_node == player_node.fsm.state_nodes.stand and player_node.input_velocity.x == 0:
		player_node.set_direction(-player_node.direction)
	player_node.set_wall_hang_detector_active(false)
	player_node.set_wall_slide_raycast_active(false)
