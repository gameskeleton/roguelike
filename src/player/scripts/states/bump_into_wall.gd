extends RkStateMachineState

enum State {fall, hit_floor, to_stand, to_crouch}

@export_group(&"References")
@export var bump_audio_stream_player: AudioStreamPlayer

var _state := State.fall
var _animation_initial_speed_scale := 1.0

func _ready() -> void:
	# references
	assert(bump_audio_stream_player != null, "bump_audio_stream_player not set")

func start_state() -> RkStateMachineState:
	_state = State.fall
	_animation_initial_speed_scale = player_node.animation.speed_scale
	player_node.audio.play_sound_effect(bump_audio_stream_player, 0.07)
	player_node.movement.dash(player_node.ROLL_BUMP_STRENGTH)
	player_node.animation.speed_scale = 1.8
	player_node.animation.play_animation(&"bump_into_wall_fall")
	player_node.collision.set_uncrouch_shapecast_active(true)
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.ROLL_DECELERATION)
	match _state:
		State.fall:
			if player_node.is_on_floor() and player_node.animation.is_animation_finished():
				_state = State.hit_floor
				player_node.animation.play_animation(&"bump_into_wall_hit_floor")
		State.hit_floor:
			if player_node.movement.is_stopped() and player_node.animation.is_animation_finished():
				if player_node.is_able_to_uncrouch() and not (player_node.input.down.is_down() and player_node.is_able_to_crouch()):
					_state = State.to_stand
					player_node.animation.play_animation(&"bump_into_wall_to_stand")
					player_node.animation.speed_scale = 1.2
				else:
					_state = State.to_crouch
					player_node.animation.play_animation(&"bump_into_wall_to_crouch")
					player_node.animation.speed_scale = 1.2
		State.to_stand:
			if player_node.movement.is_stopped() and player_node.animation.is_animation_finished():
				assert(player_node.is_able_to_uncrouch())
				return player_node.fsm.state_nodes.stand
		State.to_crouch:
			if player_node.movement.is_stopped() and player_node.animation.is_animation_finished():
				return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.crouch]):
		player_node.movement.uncrouch()
	player_node.animation.speed_scale = _animation_initial_speed_scale
	player_node.collision.set_uncrouch_shapecast_active(false)
