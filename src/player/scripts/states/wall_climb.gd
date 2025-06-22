extends RkStateMachineState

@export_group("Nodes")
@export var audio_stream_player: AudioStreamPlayer

var _animation_initial_speed_scale := 1.0

func start_state():
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.animation_player.speed_scale = 1.4
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	player_node.play_animation("wall_climb")
	player_node.play_sound_effect(audio_stream_player)
	player_node.set_wall_climb_detector_active(true)

func process_state(_delta: float):
	player_node.slot.position = Vector2(
		player_node.slot_offset.x * player_node.direction,
		player_node.slot_offset.y
	)
	if player_node.is_animation_finished():
		var can_climb_stand := not player_node.wall_climb_stand_detector.has_overlapping_bodies()
		var can_climb_crouch := not player_node.wall_climb_crouch_detector.has_overlapping_bodies()
		player_node.position = player_node.fsm.state_nodes.wall_hang.corner_pos
		player_node.velocity.y = -1
		player_node.move_and_slide()
		if can_climb_stand:
			return player_node.fsm.state_nodes.stand
		elif can_climb_crouch:
			player_node.crouch()
			return player_node.fsm.state_nodes.crouch
		else:
			push_error("cannot climb up safely")
			return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.slot.position = Vector2.ZERO
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
	player_node.set_wall_climb_detector_active(false)
