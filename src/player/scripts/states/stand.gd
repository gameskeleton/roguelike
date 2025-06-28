extends RkStateMachineState

@export_group("Nodes")
@export var stand_audio_stream_player: AudioStreamPlayer

func start_state():
	player_node.play_animation("stand")
	player_node.set_one_way_detector_active(true)
	if player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.fall, player_node.fsm.state_nodes.wall_slide]):
		player_node.play_sound_effect(stand_audio_stream_player)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.WALK_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_down.is_down() and player_node.is_able_to_crouch():
		player_node.input_down.consume()
		return player_node.fsm.state_nodes.stand_to_crouch
	if player_node.input_jump.is_pressed() and player_node.input_down.is_down() and player_node.is_on_floor_one_way():
		player_node.input_jump.consume()
		player_node.input_down.consume()
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump.is_pressed() and player_node.is_able_to_jump():
		player_node.input_jump.consume()
		return player_node.fsm.state_nodes.jump
	if player_node.input_roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input_roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input_attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input_attack.consume()
		return player_node.fsm.state_nodes.attack
	if player_node.has_same_direction(player_node.direction, player_node.input_velocity.x) and player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.push_wall
	if player_node.has_same_direction(player_node.direction, player_node.input_velocity.x) and not player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.walk
	if player_node.input_velocity.x != 0.0 and not player_node.has_same_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.turn_around

func finish_state():
	player_node.set_one_way_detector_active(false)
