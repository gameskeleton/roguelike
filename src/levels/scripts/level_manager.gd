extends Node2D

@export_group(&"Nodes")
@export var level_node: RkLevel
@export var player_node: RkPlayer
@export var player_camera_node: RkCamera2D

# @impure
func _ready() -> void:
	set_current_level_node(level_node, Vector2.ZERO, true)

# @impure
func set_current_level_node(in_level_node: RkLevel, at_pos := Vector2.ZERO, first_level := false):
	if level_node and not first_level:
		_unset_previous_level_node(level_node)
	level_node = in_level_node
	player_node.level_node = in_level_node
	if not first_level:
		add_child(in_level_node)
		level_node.position = at_pos
		level_node.reset_physics_interpolation()
		player_camera_node.reset_camera_regions()
		player_camera_node.reset_physics_interpolation()

# @impure
func _unset_previous_level_node(previous_level_node: RkLevel):
	remove_child(previous_level_node)
	previous_level_node.queue_free()
