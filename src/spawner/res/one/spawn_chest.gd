@tool
extends RkSpawnRes
class_name RkSpawnChestRes

@export var content: RkSpawnRes :
	get: return content
	set(new_content):
		if content != new_content:
			if content and Engine.is_editor_hint():
				content.changed.disconnect(emit_changed)
			content = new_content
			if content and Engine.is_editor_hint():
				content.changed.connect(emit_changed)
			if Engine.is_editor_hint():
				emit_changed()

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	var chest_node := RkObjectSpawner.spawn_chest(parent_node, global_position)
	chest_node.content = content
	return chest_node
