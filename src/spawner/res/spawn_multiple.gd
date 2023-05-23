@tool
extends RkSpawnRes
class_name RkSpawnMultipleRes

@export var multiple_spawns: Array[RkSpawnRes] = []
@export var preview_spawn_index := 0

# @override
# @impure
func spawn(parent_node: Node):
	for single_spawn in multiple_spawns:
		single_spawn.spawn(parent_node)
	return null

# @override
# @impure
func spawn_preview(parent_node: Node):
	return multiple_spawns[preview_spawn_index].spawn_preview(parent_node)
