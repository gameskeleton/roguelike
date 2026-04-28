extends RkStateMachineState

func start_state() -> RkStateMachineState:
	player_node.animation.play_animation(&"stand_to_crouch")
	player_node.collision.set_one_way_shapecast_active(true)
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.CROUCH_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.is_on_floor_one_way():
		player_node.input.jump.consume()
		player_node.input.down.consume()
		player_node.movement.drop_through_one_way()
		return player_node.fsm.state_nodes.fall
	if player_node.animation.is_animation_finished():
		return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	player_node.collision.set_one_way_shapecast_active(false)
