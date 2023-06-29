extends RkStateMachineState

const FX_STEP_RANGE := Vector2(0.99, 1.01)

@export_group("Nodes")
@export var audio_stream_player: AudioStreamPlayer
@export var footstep_left_audio_stream_player: AudioStreamPlayer
@export var footstep_right_audio_stream_player: AudioStreamPlayer

var _animation_initial_speed_scale := 1.0

func start_state():
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.animation_player.speed_scale = 1.2
	player_node.play_animation("walk")
	player_node.set_one_way_detector_active(true)
	if player_node.fsm.prev_state_node == player_node.fsm.state_nodes.fall:
		player_node.play_sound_effect(audio_stream_player)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_floor_move(delta, player_node.WALK_MAX_SPEED, player_node.WALK_ACCELERATION, player_node.WALK_DECELERATION * player_node.WALK_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_down.is_down() and player_node.is_able_to_crouch():
		return player_node.fsm.state_nodes.stand_to_crouch
	if player_node.input_jump.is_pressed() and player_node.input_down.is_down() and player_node.is_on_floor_one_way():
		player_node.input_jump.consume()
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
	if player_node.input_velocity.x != 0.0 and player_node.has_invert_direction(player_node.direction, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.turn_around
	if player_node.input_velocity.x != 0.0 and player_node.is_on_wall():
		return player_node.fsm.state_nodes.push_wall
	if player_node.input_velocity.x == 0.0 and player_node.velocity.x != 0.0:
		return player_node.fsm.state_nodes.skid
	if player_node.input_velocity.x == 0.0 and player_node.velocity.x == 0.0:
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.set_one_way_detector_active(false)

# @animation
# @impure
func fx_step_left():
	footstep_left_audio_stream_player.pitch_scale = randf_range(FX_STEP_RANGE.x, FX_STEP_RANGE.y)
	footstep_left_audio_stream_player.play()

# @impure
func fx_step_right():
	footstep_right_audio_stream_player.pitch_scale = randf_range(FX_STEP_RANGE.x, FX_STEP_RANGE.y)
	footstep_right_audio_stream_player.play()
