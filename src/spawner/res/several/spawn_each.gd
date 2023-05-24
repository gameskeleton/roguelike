@tool
extends RkSpawnRes
class_name RkSpawnEachRes

@export var each_spawns: Array[RkSpawnRes] :
	get: return each_spawns
	set(new_each_spawns):
		if each_spawns != new_each_spawns:
			if Engine.is_editor_hint():
				for each_spawn in each_spawns:
					if each_spawn:
						each_spawn.changed.disconnect(emit_changed)
			each_spawns = new_each_spawns
			if Engine.is_editor_hint():
				for each_spawn in each_spawns:
					if each_spawn:
						each_spawn.changed.connect(emit_changed)
		if Engine.is_editor_hint():
			each_preview_index = clampi(each_preview_index, 0, each_spawns.size() - 1)
			emit_changed()
@export var each_preview_index := 0 :
	get: return each_preview_index
	set(new_each_preview_index):
		if each_preview_index != new_each_preview_index:
			each_preview_index = clampi(new_each_preview_index, 0, each_spawns.size() - 1)
			if Engine.is_editor_hint():
				emit_changed()
@export var delay_between_spawn := 0.0

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	for each_spawn in each_spawns:
		if each_spawn:
			each_spawn.spawn(parent_node, global_position)
			if delay_between_spawn > 0.0:
				await parent_node.get_tree().create_timer(delay_between_spawn, false).timeout
	return null

# @override
# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	if each_spawns.is_empty() or each_preview_index > each_spawns.size() - 1 or not each_spawns[each_preview_index]:
		return null
	return each_spawns[each_preview_index].spawn_preview(parent_node, global_position)
