class_name RkPlayerAnimation

var player_node: RkPlayer

# @impure
func _init(_player_node: RkPlayer) -> void:
	player_node = _player_node

# @impure
func play_animation(animation_name: StringName) -> void:
	if not is_animation_playing(animation_name):
		player_node.animation_player.play(animation_name)

# @impure
func play_animation_then(start_animation_name: StringName, then_animation_name: StringName) -> void:
	if not is_animation_playing(start_animation_name):
		play_animation(then_animation_name)

# @pure
func is_animation_playing(animation: StringName) -> bool:
	return player_node.animation_player.current_animation == animation

# @pure
func is_animation_finished() -> bool:
	return player_node.animation_player.current_animation_position >= player_node.animation_player.current_animation_length - 0.001

# @pure
func get_animation_played_ratio() -> float:
	return clampf(player_node.animation_player.current_animation_position / (player_node.animation_player.current_animation_length - 0.001), 0.0, 1.0)
