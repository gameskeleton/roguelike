extends RkStateMachineState

var corner_pos := Vector2.ZERO

func start_state():
	corner_pos = player_node.get_corner_position()
	player_node.velocity = Vector2.ZERO
	player_node.position = \
		corner_pos \
		- Vector2(player_node.direction * 8.0, 8.0) \
		- Vector2(player_node.direction * player_node.wall_hang_hand.position.x, player_node.wall_hang_hand.position.y)
	player_node.play_animation("wall_hang")
	player_node.set_wall_hang_detector_active(true)
	player_node.set_wall_climb_detector_active(true)

func process_state(_delta: float):
	if player_node.input_up.is_just_pressed() and player_node.is_able_to_wall_climb():
		return player_node.fsm.state_nodes.wall_climb
	if player_node.input_down.is_just_pressed():
		player_node.position.x += player_node.direction * 2.5
		player_node.disable_wall_hang_timeout = player_node.WALL_HANG_DROP_TIMEOUT
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump.is_just_pressed() and player_node.has_invert_direction(player_node.direction, player_node.input_velocity.x):
		player_node.velocity.x = player_node.direction * player_node.WALL_HANG_JUMP_EXPULSE_STRENGTH
		return player_node.fsm.state_nodes.jump

func finish_state():
	player_node.set_wall_hang_detector_active(false)
	player_node.set_wall_climb_detector_active(false)
