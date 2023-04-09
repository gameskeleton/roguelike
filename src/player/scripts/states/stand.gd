extends RkStateMachineState

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func start_state():
	player_node.play_animation("stand")
	player_node.set_one_way_detector_active(true)
	if player_node.fsm.prev_state_node == player_node.fsm.state_nodes.fall or player_node.fsm.prev_state_node == player_node.fsm.state_nodes.wall_slide:
		player_node.play_sound_effect(audio_stream_player)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.RUN_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.input_pressed(player_node.input_down) and player_node.is_on_floor_one_way():
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.is_able_to_jump():
		return player_node.fsm.state_nodes.jump
	if player_node.input_just_pressed(player_node.input_roll) and player_node.is_able_to_roll():
		return player_node.fsm.state_nodes.roll
	if player_node.input_just_pressed(player_node.input_attack) and player_node.is_able_to_attack():
		return player_node.fsm.state_nodes.attack
	if player_node.input_velocity.x != 0.0 and player_node.has_same_direction(player_node.direction, player_node.input_velocity.x) and player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.push_wall
	if player_node.input_velocity.x != 0.0 and player_node.has_same_direction(player_node.direction, player_node.input_velocity.x) and not player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.walk
	if player_node.input_velocity.x != 0.0 and not player_node.has_same_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.turn_around

func finish_state():
	player_node.set_one_way_detector_active(false)
