extends RkStateMachineState

var _timer := 0.0

func start_state():
	_timer = 0.0
	if player_node.fsm.prev_state_node == player_node.fsm.state_nodes.stand_to_crouch:
		player_node.crouch()
	player_node.play_animation("crouch")
	player_node.set_crouch_detector_active(true)
	player_node.set_one_way_detector_active(true)

func process_state(delta: float):
	_timer += delta
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_direction()
	player_node.handle_deceleration_move(delta, player_node.CROUCH_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input_jump.is_pressed() and player_node.input_down.is_down() and player_node.is_on_floor_one_way():
		player_node.input_jump.consume()
		player_node.input_down.consume()
		player_node.handle_drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input_roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input_roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input_slide.is_pressed() and player_node.is_able_to_slide():
		player_node.input_slide.consume()
		return player_node.fsm.state_nodes.slide
	if player_node.input_velocity.x != 0.0 and not player_node.is_on_wall_passive():
		return player_node.fsm.state_nodes.crouch_walk
	if not player_node.input_down.is_down() and player_node.is_able_to_uncrouch() and _timer >= player_node.CROUCH_LOCK_DELAY:
		player_node.input_down.consume()
		return player_node.fsm.state_nodes.crouch_to_stand

func finish_state():
	if player_node.fsm.next_state_node != player_node.fsm.state_nodes.slide and player_node.fsm.next_state_node != player_node.fsm.state_nodes.crouch_walk:
		player_node.uncrouch()
	player_node.set_crouch_detector_active(false)
	player_node.set_one_way_detector_active(false)
