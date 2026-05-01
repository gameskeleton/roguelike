extends RkStateMachineState

@export_group(&"References")
@export var stand_audio_stream_player: AudioStreamPlayer

func _ready() -> void:
	# references
	assert(stand_audio_stream_player != null, "stand_audio_stream_player not set")

func start_state() -> RkStateMachineState:
	player_node.animation.play_animation(&"stand")
	player_node.collision.set_one_way_shapecast_active(true)
	if player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.fall, player_node.fsm.state_nodes.wall_slide]):
		player_node.audio.play_sound_effect(stand_audio_stream_player)
	if player_node.has_same_direction(player_node.direction, player_node.input.velocity.x) and not player_node.fsm.is_prev_state_node([player_node.fsm.state_nodes.wall_climb]):
		return player_node.fsm.state_nodes.walk
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.WALK_DECELERATION)
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	if player_node.input.down.is_down() and player_node.is_able_to_crouch():
		player_node.input.down.consume()
		return player_node.fsm.state_nodes.stand_to_crouch
	if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.is_on_floor_one_way():
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
	if player_node.has_same_direction(player_node.direction, player_node.input.velocity.x):
		return player_node.fsm.state_nodes.walk
	if player_node.input.has_horizontal_input() and not player_node.has_same_direction(player_node.direction, player_node.input.velocity.x):
		return player_node.fsm.state_nodes.turn_around
	return null

func finish_state() -> void:
	player_node.collision.set_one_way_shapecast_active(false)
