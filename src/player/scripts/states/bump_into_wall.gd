extends RkStateMachineState

enum State { fall, hit_floor, get_up }

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _state := State.fall
var _animation_initial_speed_scale := 1.0

func start_state():
	_state = State.fall
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.roll(player_node.direction * player_node.ROLL_BUMP_STRENGTH)
	player_node.play_animation("bump_into_wall_fall")
	player_node.play_sound_effect(audio_stream_player, 0.07)
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
				player_node.play_animation("get_up")
				player_node.animation_player.speed_scale = 1.2
		State.get_up:
			if player_node.is_stopped() and player_node.is_animation_finished():
				return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
