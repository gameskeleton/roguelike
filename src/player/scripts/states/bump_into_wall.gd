extends RkStateMachineState

enum State { fall, hit_floor, get_up }

@export_group("Nodes")
@export var audio_stream_player: AudioStreamPlayer

var _state := State.fall
var _animation_initial_speed_scale := 1.0

func start_state():
	_state = State.fall
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.roll(player_node.direction * player_node.ROLL_BUMP_STRENGTH)
	player_node.play_animation("bump_into_wall_fall")
	player_node.play_sound_effect(audio_stream_player, 0.07)
	player_node.set_crouch_detector_active(true)
	player_node.animation_player.speed_scale = 1.8

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.ROLL_DECELERATION)
	match _state:
		State.fall:
			if player_node.is_on_floor() and player_node.is_animation_finished():
				_state = State.hit_floor
				player_node.play_animation("bump_into_wall_hit_floor")
		State.hit_floor:
			if player_node.is_stopped() and player_node.is_animation_finished():
				_state = State.get_up
				if player_node.is_able_to_uncrouch():
					player_node.play_animation("get_up")
					player_node.animation_player.speed_scale = 1.2
		State.get_up:
			if player_node.is_stopped() and player_node.is_animation_finished():
				if player_node.is_able_to_uncrouch():
					return player_node.fsm.state_nodes.stand
				return player_node.fsm.state_nodes.crouch

func finish_state():
	if player_node.fsm.next_state_node != player_node.fsm.state_nodes.crouch:
		player_node.uncrouch()
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.set_crouch_detector_active(false)
