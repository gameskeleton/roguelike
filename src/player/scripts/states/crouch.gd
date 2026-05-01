extends RkStateMachineState

var _timer := 0.0

func start_state() -> RkStateMachineState:
	_timer = 0.0
	if player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.stand_to_crouch]):
		player_node.movement.crouch()
	player_node.animation.play_animation(&"crouch")
	player_node.collision.set_one_way_shapecast_active(true)
	player_node.collision.set_uncrouch_shapecast_active(true)
	if player_node.input.has_horizontal_input():
		return player_node.fsm.state_nodes.crouch_walk
	return null

func process_state(delta: float) -> RkStateMachineState:
	_timer += delta
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_direction()
	player_node.movement.apply_floor_deceleration(delta, player_node.CROUCH_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.movement.is_on_floor_one_way():
		player_node.input.jump.consume()
		player_node.input.down.consume()
		player_node.movement.drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input.roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input.roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input.slide.is_pressed() and player_node.is_able_to_slide():
		player_node.input.slide.consume()
		return player_node.fsm.state_nodes.slide
	if player_node.input.attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input.attack.consume()
		return player_node.fsm.state_nodes.crouch_attack
	if player_node.input.has_horizontal_input():
		return player_node.fsm.state_nodes.crouch_walk
	if not player_node.input.down.is_down() and player_node.is_able_to_uncrouch() and _timer >= player_node.CROUCH_LOCK_DELAY:
		player_node.input.down.consume()
		return player_node.fsm.state_nodes.crouch_to_stand
	return null

func finish_state() -> void:
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.slide, player_node.fsm.state_nodes.crouch_walk, player_node.fsm.state_nodes.crouch_attack]):
		player_node.movement.uncrouch()
	player_node.collision.set_one_way_shapecast_active(false)
	player_node.collision.set_uncrouch_shapecast_active(false)
