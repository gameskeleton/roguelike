extends RkStateMachineState

var _timer := 0.0

func start_state():
	_timer = 0.0
	if player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.stand_to_crouch]):
		player_node.crouch()
	player_node.play_animation("crouch")
	player_node.set_one_way_shapecast_active(true)
	player_node.set_uncrouch_shapecast_active(true)
	if player_node.has_horizontal_input():
		return player_node.fsm.state_nodes.crouch_walk

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
	if player_node.input_attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input_attack.consume()
		return player_node.fsm.state_nodes.crouch_attack
	if player_node.has_horizontal_input():
		return player_node.fsm.state_nodes.crouch_walk
	if not player_node.input_down.is_down() and player_node.is_able_to_uncrouch() and _timer >= player_node.CROUCH_LOCK_DELAY:
		player_node.input_down.consume()
		return player_node.fsm.state_nodes.crouch_to_stand

func finish_state():
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.slide, player_node.fsm.state_nodes.crouch_walk, player_node.fsm.state_nodes.crouch_attack]):
		player_node.uncrouch()
	player_node.set_one_way_shapecast_active(false)
	player_node.set_uncrouch_shapecast_active(false)
