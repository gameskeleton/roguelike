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

func process_state(_delta: float):
	if player_node.input_just_pressed(player_node.input_up):
		return player_node.fsm.state_nodes.wall_climb
	if player_node.input_just_pressed(player_node.input_down):
		player_node.position.x += player_node.direction * 2.5
		player_node.disable_wall_hang_timeout = player_node.WALL_HANG_DROP_TIMEOUT
		return player_node.fsm.state_nodes.fall
