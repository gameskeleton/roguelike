extends RkStateMachineState

var corner_pos := Vector2.ZERO

func start_state():
	corner_pos = player_node.get_corner_tile_pos_at_hand()
	player_node.velocity = Vector2.ZERO
	player_node.position = \
		corner_pos \
		- Vector2(player_node.direction * 5.0, 6.0) \
		- Vector2(player_node.direction * absf(player_node.hand_marker.position.x), player_node.hand_marker.position.y)
	player_node.play_animation("wall_hang")
	player_node.set_wall_hang_raycast_active(true)
	player_node.set_wall_climb_shapecast_active(true)

func process_state(_delta: float):
	if player_node.input_up.is_pressed() and player_node.is_able_to_wall_climb():
		player_node.input_up.consume()
		return player_node.fsm.state_nodes.wall_climb
	if player_node.input_down.is_pressed():
		player_node.input_down.consume()
		player_node.disable_wall_hang_timeout = player_node.WALL_HANG_DROP_TIMEOUT
		if player_node.has_same_direction(player_node.direction, player_node.input_velocity.x):
			return player_node.fsm.state_nodes.wall_slide
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump.is_pressed() and player_node.has_invert_direction(player_node.direction, player_node.input_velocity.x):
		player_node.input_jump.consume()
		player_node.velocity.x = player_node.direction * player_node.WALL_HANG_JUMP_EXPULSE_STRENGTH
		return player_node.fsm.state_nodes.jump

func finish_state():
	player_node.set_wall_hang_raycast_active(false)
	player_node.set_wall_climb_shapecast_active(false)
