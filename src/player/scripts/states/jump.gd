extends RkStateMachineState

var _jump_strength := 0.0
var _was_wall_sliding := false

func start_state() -> RkStateMachineState:
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
	player_node.movement.jump(_jump_strength)
	player_node.animation.play_animation(&"jump")
	if not _was_wall_sliding and player_node.input.has_horizontal_input():
		player_node.set_direction(int(signf(player_node.input.velocity.x)))
	return null

func process_state(delta: float) -> RkStateMachineState:
	_apply_gravity(delta)
	_apply_direction(delta)
	_apply_airborne_move(delta)
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand
	if player_node.is_on_ceiling():
		player_node.velocity.y = player_node.CEILING_KNOCKDOWN
		return player_node.fsm.state_nodes.fall
	if player_node.velocity.y > 0.0:
		return player_node.fsm.state_nodes.fall
	if player_node.input.attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input.attack.consume()
		return player_node.fsm.state_nodes.attack
	return null

func _apply_gravity(delta: float) -> void:
	var gravity_acceleration := player_node.GRAVITY_ACCELERATION if player_node.input.jump.is_down() else player_node.GRAVITY_FAST_ACCELERATION
	player_node.movement.apply_gravity(delta, player_node.GRAVITY_MAX_SPEED, gravity_acceleration)

func _apply_direction(_delta: float) -> void:
	if not _was_wall_sliding:
		player_node.movement.apply_direction()

func _apply_airborne_move(delta: float) -> void:
	player_node.movement.apply_airborne_move_input(delta, player_node.WALK_MAX_SPEED, player_node.WALK_ACCELERATION, player_node.WALK_DECELERATION)
