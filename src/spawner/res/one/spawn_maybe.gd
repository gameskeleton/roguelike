@tool
extends RkSpawnRes
class_name RkSpawnMaybeRes

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
@export var probability := 0.5

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	if content:
		var main_node := RkMain.get_main_node()
		if probability > main_node.rng.randf():
			return content.spawn(parent_node, global_position)
	return null

# @override
# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	if content:
		return content.spawn_preview(parent_node, global_position)
	return null
