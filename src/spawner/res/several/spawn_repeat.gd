@tool
extends RkSpawnRes
class_name RkSpawnRepeatRes

@export var repeat := 1
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
@export var delay_between_spawn := 0.0

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	if content:
		for i in repeat:
			content.spawn(parent_node, global_position)
			if delay_between_spawn > 0.0:
				await parent_node.get_tree().create_timer(delay_between_spawn, false).timeout
	return null

# @override
# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	if content:
		return content.spawn_preview(parent_node, global_position)
	return null
