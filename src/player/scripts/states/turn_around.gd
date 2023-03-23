extends RkStateMachineState

var _initial_direction := 0.0
const TURN_AROUND_OFFSET := -2.0

func start_state():
	_initial_direction = player_node.direction
	player_node.sprite.offset.x += player_node.direction * TURN_AROUND_OFFSET
	player_node.play_animation("turn_around")
	if player_node.velocity.x == 0:
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.walk

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.RUN_DECELERATION * player_node.RUN_DECELERATION_BRAKE)
	if not player_node.is_on_floor():
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump_once and player_node.is_able_to_jump():
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.jump
	if player_node.has_same_direction(player_node.velocity.x, player_node.input_velocity.x):
		return player_node.fsm.state_nodes.walk
	if player_node.is_animation_finished():
		player_node.set_direction(-player_node.direction)
		return player_node.fsm.state_nodes.stand

func finish_state():
	if player_node.direction == _initial_direction:
		player_node.sprite.offset.x += player_node.direction * TURN_AROUND_OFFSET
