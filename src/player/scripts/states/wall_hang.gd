extends RkStateMachineState

var corner_pos := Vector2.ZERO

func start_state() -> RkStateMachineState:
	corner_pos = player_node.movement.get_corner_tile_pos_at_hand()
	player_node.velocity = Vector2.ZERO
	player_node.position = \
		corner_pos \
		- Vector2(player_node.direction * 5.0, 6.0) \
		- Vector2(player_node.direction * absf(player_node.hand_marker.position.x), player_node.hand_marker.position.y)
	player_node.animation.play_animation(&"wall_hang")
	player_node.collision.set_wall_hang_raycast_active(true)
	player_node.collision.set_wall_slide_raycast_active(true)
	player_node.collision.set_wall_climb_shapecast_active(true)
	return null

func process_state(_delta: float) -> RkStateMachineState:
	if player_node.input.up.is_pressed() and player_node.is_able_to_wall_climb():
		player_node.input.up.consume()
		return player_node.fsm.state_nodes.wall_climb
	if player_node.input.down.is_pressed():
		player_node.input.down.consume()
		player_node.disable_wall_hang_timeout = player_node.WALL_HANG_DROP_TIMEOUT
		if player_node.movement.is_facing_with_input() and player_node.is_able_to_wall_slide():
			return player_node.fsm.state_nodes.wall_slide
		return player_node.fsm.state_nodes.fall
	if player_node.input.jump.is_pressed() and player_node.is_able_to_jump() and player_node.movement.is_facing_against_input():
		player_node.input.jump.consume()
		player_node.velocity.x = player_node.direction * player_node.WALL_HANG_JUMP_EXPULSE_STRENGTH
		return player_node.fsm.state_nodes.jump
	return null

func finish_state() -> void:
	player_node.collision.set_wall_hang_raycast_active(false)
	player_node.collision.set_wall_slide_raycast_active(false)
	player_node.collision.set_wall_climb_shapecast_active(false)
