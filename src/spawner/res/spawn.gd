@tool
extends Resource
class_name RkSpawnRes

# @abstract
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	push_error("RkSpawnRes::spawn is abstract: %s %s" % [parent_node.name, global_position])
	return null

# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	return spawn(parent_node, global_position)
