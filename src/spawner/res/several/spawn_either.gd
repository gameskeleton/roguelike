@tool
extends RkSpawnRes
class_name RkSpawnEitherRes

@export var either_spawns: Array[RkSpawnRes] :
	get: return either_spawns
	set(new_either_spawns):
		if either_spawns != new_either_spawns:
			if Engine.is_editor_hint():
				for either_spawn in either_spawns:
					if either_spawn:
						either_spawn.changed.disconnect(emit_changed)
			either_spawns = new_either_spawns
			if Engine.is_editor_hint():
				for either_spawn in either_spawns:
					if either_spawn:
						either_spawn.changed.connect(emit_changed)
		if Engine.is_editor_hint():
			either_preview_index = clampi(either_preview_index, 0, either_spawns.size() - 1)
			emit_changed()
@export var either_preview_index := 0 :
	get: return either_preview_index
	set(new_either_preview_index):
		if either_preview_index != new_either_preview_index:
			either_preview_index = clampi(new_either_preview_index, 0, either_spawns.size() - 1)
			if Engine.is_editor_hint():
				emit_changed()

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	var picked_spawn := RkUtils.pick_random(either_spawns, RkMain.get_main_node().spawn_rng) as RkSpawnRes
	if picked_spawn:
		return picked_spawn.spawn(parent_node, global_position)
	return null

# @override
# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	if either_spawns.is_empty() or either_preview_index > either_spawns.size() - 1 or not either_spawns[either_preview_index]:
		return null
	return either_spawns[either_preview_index].spawn_preview(parent_node, global_position)
