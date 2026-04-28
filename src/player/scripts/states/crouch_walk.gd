extends RkStateMachineState

const FX_STEP_RANGE := Vector2(0.95, 1.05)

@export var footstep_left_streams: Array[AudioStream]
@export var footstep_right_streams: Array[AudioStream]

@export_group(&"Nodes")
@export var footstep_left_audio_stream_player: AudioStreamPlayer
@export var footstep_right_audio_stream_player: AudioStreamPlayer

var _timer := 0.0

func start_state() -> RkStateMachineState:
	_timer = 0.0
	_play_animation()
	player_node.collision.set_one_way_shapecast_active(true)
	player_node.collision.set_uncrouch_shapecast_active(true)
	return null

func process_state(delta: float) -> RkStateMachineState:
	_timer += delta
	_play_animation()
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_direction()
	player_node.movement.apply_floor_move_input(delta, player_node.CROUCH_MAX_SPEED, player_node.CROUCH_ACCELERATION, player_node.CROUCH_DECELERATION * player_node.CROUCH_DECELERATION_BRAKE)
	if player_node.is_on_wall():
		player_node.velocity.x = 0.0
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.is_on_floor_one_way():
		player_node.input.jump.consume()
		player_node.input.down.consume()
		player_node.movement.drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if not player_node.input.down.is_down() and player_node.is_able_to_uncrouch() and _timer >= player_node.CROUCH_LOCK_DELAY:
		player_node.input.down.consume()
		return player_node.fsm.state_nodes.crouch_to_stand
	if player_node.input.roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input.roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input.slide.is_pressed() and player_node.is_able_to_slide():
		player_node.input.slide.consume()
		return player_node.fsm.state_nodes.slide
	if player_node.input.attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input.attack.consume()
		return player_node.fsm.state_nodes.crouch_attack
	if not player_node.input.has_horizontal_input():
		return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.slide, player_node.fsm.state_nodes.crouch, player_node.fsm.state_nodes.crouch_attack]):
		player_node.movement.uncrouch()
	player_node.collision.set_one_way_shapecast_active(false)
	player_node.collision.set_uncrouch_shapecast_active(false)

# @impure
func _play_animation() -> void:
	player_node.animation.play_animation(&"crouch" if player_node.get_real_velocity().length() < 20.0 else &"crouch_walk")

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
