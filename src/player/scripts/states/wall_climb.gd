extends RkStateMachineState

@export_group("Nodes")
@export var climb_audio_stream_player: AudioStreamPlayer

var _initial_position := Vector2.ZERO
var _animation_initial_speed_scale := 1.0

func start_state():
	_initial_position = player_node.position
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.root_motion = Vector2.ZERO
	player_node.animation_player.speed_scale = 1.4
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	player_node.play_animation("wall_climb")
	player_node.play_sound_effect(climb_audio_stream_player, 0.0, 0.7, 0.8)
	player_node.set_wall_climb_detector_active(true)

func process_state(_delta: float):
	player_node.position = _initial_position + player_node.root_motion * Vector2(player_node.direction, 1.0)
	if player_node.is_animation_finished():
		var can_climb_stand := not player_node.wall_climb_stand_detector.has_overlapping_bodies()
		var can_climb_crouch := not player_node.wall_climb_crouch_detector.has_overlapping_bodies()
		player_node.position = player_node.fsm.state_nodes.wall_hang.corner_pos + Vector2(0.0, -8.0)
		if can_climb_stand:
			return player_node.fsm.state_nodes.stand
		elif can_climb_crouch:
			player_node.crouch()
			return player_node.fsm.state_nodes.crouch
		else:
			push_error("cannot climb up safely")
			return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.root_motion = Vector2.ZERO
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
	player_node.set_wall_climb_detector_active(false)
