extends RkStateMachineState

func start_state() -> RkStateMachineState:
	player_node.collision.set_one_way_shapecast_active(true)
	if player_node.input.has_horizontal_input() and player_node.movement.is_facing_away_from_input():
		return player_node.fsm.state_nodes.turn_around
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.WALK_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.movement.is_on_floor_one_way():
		player_node.input.jump.consume()
		player_node.input.down.consume()
		player_node.movement.drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.is_able_to_jump():
		player_node.input.jump.consume()
		return player_node.fsm.state_nodes.jump
	if player_node.input.roll.is_pressed() and player_node.is_able_to_roll():
		player_node.input.roll.consume()
		return player_node.fsm.state_nodes.roll
	if player_node.input.attack.is_pressed() and player_node.is_able_to_attack():
		player_node.input.attack.consume()
		return player_node.fsm.state_nodes.attack
	if player_node.movement.is_facing_away_from_input():
		return player_node.fsm.state_nodes.turn_around
	if player_node.movement.is_stopped():
		return player_node.fsm.state_nodes.stand
	return null

func finish_state() -> void:
	player_node.collision.set_one_way_shapecast_active(false)
