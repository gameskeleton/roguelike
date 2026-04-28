extends RkStateMachineState

@export_group(&"Nodes")
@export var climb_audio_stream_player: AudioStreamPlayer

var _can_climb_stand := false
var _can_climb_crouch := false
var _initial_position := Vector2.ZERO
var _initial_animation_speed_scale := 1.0
var _initial_physics_interpolation_mode := Node.PHYSICS_INTERPOLATION_MODE_INHERIT

func start_state() -> RkStateMachineState:
	player_node.collision.set_wall_climb_shapecast_active(true)
	_can_climb_stand = not player_node.wall_climb_stand_shapecast.is_colliding()
	_can_climb_crouch = not player_node.wall_climb_crouch_shapecast.is_colliding()
	_initial_position = player_node.position
	_initial_animation_speed_scale = player_node.animation_player.speed_scale
	_initial_physics_interpolation_mode = player_node.physics_interpolation_mode
	player_node.root_motion = Vector2.ZERO
	player_node.animation_player.speed_scale = 1.4
	player_node.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	player_node.audio.play_sound_effect(climb_audio_stream_player, 0.0, 0.7, 0.8)
	player_node.animation.play_animation(&"wall_climb")
	assert(_can_climb_stand or _can_climb_crouch, "cannot climb safely")
	return null

func process_state(_delta: float) -> RkStateMachineState:
	player_node.position = _initial_position + player_node.root_motion * Vector2(player_node.direction, 1.0)
	if player_node.animation.is_animation_finished():
		player_node.position = player_node.fsm.state_nodes.wall_hang.corner_pos + Vector2(0.0, -8.0)
		player_node.movement.reset_safe_margin_after_teleport()
		if _can_climb_stand:
			return player_node.fsm.state_nodes.stand
		else:
			player_node.movement.crouch()
			return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	player_node.root_motion = Vector2.ZERO
	player_node.animation_player.speed_scale = _initial_animation_speed_scale
	player_node.physics_interpolation_mode = _initial_physics_interpolation_mode
	player_node.collision.set_wall_climb_shapecast_active(false)
