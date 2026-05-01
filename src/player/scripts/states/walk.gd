extends RkStateMachineState

const FX_STEP_RANGE := Vector2(0.95, 1.05)

@export_group(&"Audio")
@export var footstep_left_streams: Array[AudioStream]
@export var footstep_right_streams: Array[AudioStream]

@export_group(&"References")
@export var stand_audio_stream_player: AudioStreamPlayer
@export var footstep_left_audio_stream_player: AudioStreamPlayer
@export var footstep_right_audio_stream_player: AudioStreamPlayer

var _animation_initial_speed_scale := 1.0

func _ready() -> void:
	# references
	assert(stand_audio_stream_player != null, "stand_audio_stream_player not set")
	assert(footstep_left_audio_stream_player != null, "footstep_left_audio_stream_player not set")
	assert(footstep_right_audio_stream_player != null, "footstep_right_audio_stream_player not set")

func start_state() -> RkStateMachineState:
	_apply_animation()
	_animation_initial_speed_scale = player_node.animation.speed_scale
	player_node.animation.speed_scale = 1.2
	player_node.collision.set_one_way_shapecast_active(true)
	if player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.fall]):
		player_node.audio.play_sound_effect(stand_audio_stream_player)
	return null

func process_state(delta: float) -> RkStateMachineState:
	_apply_animation()
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_move_input(delta, player_node.WALK_MAX_SPEED, player_node.WALK_ACCELERATION, player_node.WALK_DECELERATION * player_node.WALK_DECELERATION_BRAKE)
	if player_node.is_on_wall():
		player_node.velocity.x = 0.0
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input.down.is_down() and player_node.is_able_to_crouch():
		player_node.input.down.consume()
		return player_node.fsm.state_nodes.stand_to_crouch
	if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.is_on_floor_one_way():
		player_node.input.jump.consume()
		player_node.input.down.consume()
		player_node.movement.drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.is_able_to_jump():
		player_node.input.jump.consume()
		return player_node.fsm.state_nodes.jump
	if player_node.input.roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input.roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input.attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input.attack.consume()
		return player_node.fsm.state_nodes.attack
	if player_node.input.has_horizontal_input() and player_node.has_invert_direction(player_node.direction, player_node.input.velocity.x):
		return player_node.fsm.state_nodes.turn_around
	if not player_node.input.has_horizontal_input():
		return player_node.fsm.state_nodes.skid if not player_node.is_stopped() else player_node.fsm.state_nodes.stand
	return null

func finish_state() -> void:
	player_node.animation.speed_scale = _animation_initial_speed_scale
	player_node.collision.set_one_way_shapecast_active(false)

# @impure
func _apply_animation() -> void:
	player_node.animation.play_animation(&"stand" if player_node.get_real_velocity().length() < 0.15 * player_node.WALK_MAX_SPEED else &"walk")

# @anim
# @impure
func _fx_step_left() -> void:
	footstep_left_audio_stream_player.stream = footstep_left_streams.pick_random()
	player_node.audio.play_sound_effect(footstep_left_audio_stream_player, 0.0, FX_STEP_RANGE.x, FX_STEP_RANGE.y)

# @anim
# @impure
func _fx_step_right() -> void:
	footstep_right_audio_stream_player.stream = footstep_right_streams.pick_random()
	player_node.audio.play_sound_effect(footstep_right_audio_stream_player, 0.0, FX_STEP_RANGE.x, FX_STEP_RANGE.y)
