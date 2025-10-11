extends Node2D

@export_group(&"Nodes")
@export var level_node: RkLevel
@export var player_node: RkPlayer
@export var player_camera_node: RkCamera2D

# @impure
func _ready() -> void:
	set_current_level_node(level_node, true)

# @impure
func set_current_level_node(in_level_node: RkLevel, first_level := false):
	if level_node and not first_level:
		_unset_previous_level_node(level_node)
	level_node = in_level_node
	player_node.level_node = in_level_node

# @impure
func _unset_previous_level_node(_previous_level_node: RkLevel):
	pass
