extends RkStateMachineState

const FX_STEP_RANGE := Vector2(0.95, 1.05)

@export var footstep_left_streams: Array[AudioStream]
@export var footstep_right_streams: Array[AudioStream]

@export_group("Nodes")
@export var footstep_left_audio_stream_player: AudioStreamPlayer
@export var footstep_right_audio_stream_player: AudioStreamPlayer

var _timer := 0.0

func start_state():
	_timer = 0.0
	_play_animation()
	player_node.set_one_way_shapecast_active(true)
	player_node.set_uncrouch_shapecast_active(true)

func process_state(delta: float):
	_timer += delta
	_play_animation()
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_floor_move(delta, player_node.CROUCH_MAX_SPEED, player_node.CROUCH_ACCELERATION, player_node.CROUCH_DECELERATION * player_node.CROUCH_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump.is_pressed() and player_node.input_down.is_down() and player_node.is_on_floor_one_way():
		player_node.input_jump.consume()
		player_node.input_down.consume()
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if not player_node.input_down.is_down() and player_node.is_able_to_uncrouch() and _timer >= player_node.CROUCH_LOCK_DELAY:
		player_node.input_down.consume()
		return player_node.fsm.state_nodes.crouch_to_stand
	if player_node.input_roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input_roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input_slide.is_pressed() and player_node.is_able_to_slide():
		player_node.input_slide.consume()
		return player_node.fsm.state_nodes.slide
	if player_node.input_velocity.x == 0.0:
		return player_node.fsm.state_nodes.crouch

func finish_state():
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.slide, player_node.fsm.state_nodes.crouch]):
		player_node.uncrouch()
	player_node.set_one_way_shapecast_active(false)
	player_node.set_uncrouch_shapecast_active(false)

# @impure
func _play_animation():
	player_node.play_animation("crouch" if player_node.get_real_velocity().length() < 20.0 else "crouch_walk")

# @animation
# @impure
func fx_step_left():
	footstep_left_audio_stream_player.stream = footstep_left_streams.pick_random()
	player_node.play_sound_effect(footstep_left_audio_stream_player, 0.0, FX_STEP_RANGE.x, FX_STEP_RANGE.y)

# @animation
# @impure
func fx_step_right():
	footstep_right_audio_stream_player.stream = footstep_right_streams.pick_random()
	player_node.play_sound_effect(footstep_right_audio_stream_player, 0.0, FX_STEP_RANGE.x, FX_STEP_RANGE.y)
