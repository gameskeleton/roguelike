extends RkStateMachineState

func start_state():
	player_node.velocity = Vector2.ZERO
	player_node.position = player_node.get_corner_position() + (Vector2(player_node.direction * -6.0, 11.0))
	player_node.play_animation("wall_hang")

func process_state(_delta: float):
	if player_node.input_just_pressed(player_node.input_up):
		return player_node.fsm.state_nodes.wall_climb
	if player_node.input_just_pressed(player_node.input_down):
		return player_node.fsm.state_nodes.fall
