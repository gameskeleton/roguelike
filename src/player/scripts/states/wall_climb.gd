extends RkStateMachineState

@export_group("Nodes")
@export var climb_audio_stream_player: AudioStreamPlayer

var _can_climb_stand := false
var _can_climb_crouch := false
var _initial_position := Vector2.ZERO
var _animation_initial_speed_scale := 1.0

func start_state():
	player_node.set_wall_climb_shapecast_active(true)
	_can_climb_stand = not player_node.wall_climb_stand_shapecast.is_colliding()
	_can_climb_crouch = not player_node.wall_climb_crouch_shapecast.is_colliding()
	_initial_position = player_node.position
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.root_motion = Vector2.ZERO
	player_node.animation_player.speed_scale = 1.4
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	player_node.play_animation("wall_climb")
	player_node.play_sound_effect(climb_audio_stream_player, 0.0, 0.7, 0.8)
	assert(_can_climb_stand or _can_climb_crouch, "cannot climb safely")

func process_state(_delta: float):
	player_node.position = _initial_position + player_node.root_motion * Vector2(player_node.direction, 1.0)
	if player_node.is_animation_finished():
		player_node.position = player_node.fsm.state_nodes.wall_hang.corner_pos + Vector2(0.0, -8.0)
		player_node.handle_safe_margin_after_teleport()
		if _can_climb_stand:
			return player_node.fsm.state_nodes.stand
		else:
			player_node.crouch()
			return player_node.fsm.state_nodes.crouch

func finish_state():
	player_node.root_motion = Vector2.ZERO
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_INHERIT
	player_node.set_wall_climb_shapecast_active(false)
