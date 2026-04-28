class_name RkPlayerAudio

var player_node: RkPlayer

# @impure
func _init(_player_node: RkPlayer) -> void:
	player_node = _player_node

# @impure
func stop_sound_effect(audio_stream_player: AudioStreamPlayer) -> void:
	audio_stream_player.stop()

# @impure
func play_sound_effect(audio_stream_player: AudioStreamPlayer, from_position := 0.0, low_pitch := 0.98, high_pitch := 1.02) -> void:
	audio_stream_player.pitch_scale = randf_range(low_pitch, high_pitch)
	audio_stream_player.play(from_position)
