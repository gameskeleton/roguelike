@tool
extends RkSpawnRes
class_name RkSpawnChestRes

@export var content: RkSpawnRes

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	var chest_node := RkObjectSpawner.spawn_chest(parent_node, RkUtils.node_global_position(parent_node))
	chest_node.content = content
	return chest_node
