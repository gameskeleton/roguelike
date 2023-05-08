extends RkStateMachineState

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _animation_initial_speed_scale := 1.0

func start_state():
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.animation_player.speed_scale = 1.4
	player_node.play_animation("wall_climb")
	player_node.play_sound_effect(audio_stream_player)

func process_state(_delta: float):
	if player_node.is_animation_finished():
		player_node.position = player_node.fsm.state_nodes.wall_hang.corner_pos
		player_node.velocity.y = -1
		player_node.move_and_slide()
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
