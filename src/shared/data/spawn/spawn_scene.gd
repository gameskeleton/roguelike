@tool
extends RkSpawnRes
class_name RkSpawnSceneRes

@export var scene: PackedScene
@export var params := {}

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	if not scene:
		return null
	var node := scene.instantiate()
	for param_key in params.keys():
		node.set(param_key, params[param_key])
	parent_node.add_child(node)
	return node
