extends RkStateMachineState

enum State {fall, hit_floor, dead}

var _state := State.fall
var _animation_initial_speed_scale := 1.0

func start_state() -> RkStateMachineState:
	_state = State.fall
	_animation_initial_speed_scale = player_node.animation.speed_scale
	player_node.animation.speed_scale = 1.4
	player_node.animation.play_animation(&"death_fall")
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.DEATH_DECELERATION)
	match _state:
		State.fall:
			if player_node.is_on_floor() and player_node.animation.is_animation_finished():
				_state = State.hit_floor
				player_node.animation.play_animation(&"death_hit_floor")
		State.hit_floor:
			if player_node.movement.is_stopped() and player_node.animation.is_animation_finished():
				_state = State.dead
	return null

func finish_state() -> void:
	player_node.animation.speed_scale = _animation_initial_speed_scale
