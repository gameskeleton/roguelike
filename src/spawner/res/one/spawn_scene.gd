@tool
extends RkSpawnRes
class_name RkSpawnSceneRes

@export var scene: PackedScene :
	get: return scene
	set(new_scene):
		if scene != new_scene:
			scene = new_scene
			if Engine.is_editor_hint():
				emit_changed()
@export var params := {}
@export var spawn_at_position := false :
	get: return spawn_at_position
	set(new_spawn_at_position):
		if spawn_at_position != new_spawn_at_position:
			spawn_at_position = new_spawn_at_position
			if Engine.is_editor_hint():
				emit_changed()

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	if scene:
		var node := scene.instantiate()
		if spawn_at_position:
			if node is Node2D or node is Control:
				node.global_position = global_position
		for param_key in params.keys():
			node.set(param_key, params[param_key])
		parent_node.add_child(node)
		return node
	return null
