@tool
extends Resource
class_name RkSpawnRes

# @abstract
# @impure
func spawn(parent_node: Node) -> Node:
	push_error("RkSpawnRes::spawn is abstract: %s" % [parent_node.name])
	return null

# @impure
func spawn_preview(parent_node: Node) -> Node:
	return spawn(parent_node)
