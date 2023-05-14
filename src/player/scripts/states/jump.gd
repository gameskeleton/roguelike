extends RkStateMachineState

var _jump_strength := 0.0
var _was_wall_sliding := false

func start_state():
	_was_wall_sliding = false
	# compute jump strength
	match player_node.fsm.prev_state_node:
		player_node.fsm.state_nodes.wall_hang:
			_jump_strength = player_node.WALL_HANG_JUMP_STRENGTH
		player_node.fsm.state_nodes.wall_slide:
			_jump_strength = player_node.WALL_SLIDE_JUMP_STRENGTH
			_was_wall_sliding = true
		_:
			_jump_strength = player_node.JUMP_STRENGTH
	# apply jump
	player_node.jump(_jump_strength)
	player_node.play_animation("jump")
	if not _was_wall_sliding and player_node.input_velocity.x != 0.0:
		player_node.set_direction(int(sign(player_node.input_velocity.x)))

func process_state(delta: float):
	_handle_direction()
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_airborne_move(delta, player_node.RUN_MAX_SPEED, player_node.RUN_ACCELERATION, player_node.RUN_DECELERATION)
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand
	if player_node.is_on_ceiling():
		player_node.velocity.y = player_node.CEILING_KNOCKDOWN
		return player_node.fsm.state_nodes.fall
	if player_node.velocity.y > 0.0:
		return player_node.fsm.state_nodes.fall
	if player_node.input_just_pressed(player_node.input_attack) and player_node.is_able_to_attack():
		return player_node.fsm.state_nodes.attack

func _handle_direction():
	if not _was_wall_sliding:
		player_node.handle_direction()
