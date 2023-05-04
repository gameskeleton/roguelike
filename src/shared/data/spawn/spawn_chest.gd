@tool
extends RkSpawnRes
class_name RkSpawnChestRes

const CHEST_SCENE: PackedScene = preload("res://src/objects/pickups/chest.tscn")

@export var content: RkSpawnRes

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	var chest_node := CHEST_SCENE.instantiate()
	chest_node.content = content
	parent_node.add_child(chest_node)
	return chest_node
