extends RkStateMachineState

func start_state():
	player_node.play_animation("wall_hang")

func process_state(_delta: float):
	if player_node.input_just_pressed(player_node.input_jump):
		return player_node.fsm.state_nodes.fall
