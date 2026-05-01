extends RkStateMachineState

var _coyote_time := 0.0

func start_state() -> RkStateMachineState:
	player_node.animation.play_animation(&"jump_to_fall")
	player_node.collision.set_wall_hang_raycast_active(true)
	player_node.collision.set_wall_slide_raycast_active(true)
	_coyote_time = player_node.COYOTE_TIME if player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.walk, player_node.fsm.state_nodes.crouch_walk]) else 0.0
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.animation.play_animation_then("jump_to_fall", "fall")
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_direction()
	player_node.movement.apply_airborne_move_input(delta, player_node.WALK_MAX_SPEED, player_node.WALK_ACCELERATION, player_node.WALK_DECELERATION)
	_coyote_time -= delta
	if player_node.is_on_floor():
		return player_node.fsm.state_nodes.stand if player_node.movement.is_stopped() else player_node.fsm.state_nodes.walk
	if player_node.input.jump.is_pressed() and player_node.is_able_to_jump() and _coyote_time > 0.0:
		player_node.input.jump.consume()
		return player_node.fsm.state_nodes.jump
	if player_node.input.attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input.attack.consume()
		return player_node.fsm.state_nodes.attack
	if player_node.is_able_to_wall_hang():
		return player_node.fsm.state_nodes.wall_hang
	if player_node.movement.is_facing_with_input() and player_node.is_able_to_wall_slide():
		return player_node.fsm.state_nodes.wall_slide
	return null

func finish_state() -> void:
	player_node.collision.set_wall_hang_raycast_active(false)
	player_node.collision.set_wall_slide_raycast_active(false)
