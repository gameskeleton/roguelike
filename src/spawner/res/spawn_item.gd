@tool
extends RkSpawnRes
class_name RkSpawnItemRes

@export var item: RkItemRes
@export var expulse_cone := 35.0
@export var expulse_strength := Vector2(180.0, 200.0)
@export var expulse_direction := Vector2.UP

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	if not item:
		return null
	var pickup_item_node := RkObjectSpawner.spawn_item(parent_node, RkUtils.node_global_position(parent_node))
	pickup_item_node.fly(expulse_direction, expulse_cone, expulse_strength)
	return pickup_item_node
