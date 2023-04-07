extends RkStateMachineState

var _animation_initial_speed_scale := 1.0

func start_state():
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.animation_player.speed_scale = 1.4
	player_node.play_animation("wall_climb")

func process_state(_delta: float):
	if player_node.is_animation_finished():
		player_node.position = player_node.get_corner_position() + Vector2(player_node.direction * 8.0, -21.0)
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
