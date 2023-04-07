extends RkStateMachineState

func start_state():
	player_node.velocity = Vector2(player_node.direction, min(player_node.velocity.y, player_node.WALL_SLIDE_ENTER_MAX_VERTICAL_VELOCITY))
	player_node.play_animation("wall_slide")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.WALL_SLIDE_GRAVITY_MAX_SPEED, player_node.WALL_SLIDE_GRAVITY_ACCELERATION)
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand
	if not player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.is_able_to_jump():
		player_node.velocity.x = player_node.direction * player_node.WALL_JUMP_EXPULSE_STRENGTH
		return player_node.fsm.state_nodes.jump

func finish_state():
	player_node.set_direction(-player_node.direction)
