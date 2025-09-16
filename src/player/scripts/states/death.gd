extends RkStateMachineState

enum State {fall, hit_floor, dead}

var _state := State.fall
var _animation_initial_speed_scale := 1.0

func start_state():
	_state = State.fall
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.play_animation(&"death_fall")
	player_node.animation_player.speed_scale = 1.4

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.DEATH_DECELERATION)
	match _state:
		State.fall:
			if player_node.is_on_floor() and player_node.is_animation_finished():
				_state = State.hit_floor
				player_node.play_animation(&"death_hit_floor")
		State.hit_floor:
			if player_node.is_stopped() and player_node.is_animation_finished():
				_state = State.dead

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
