@tool
extends RkSpawnRes
class_name RkSpawnRandomRes

@export var random_spawns: Array[RkSpawnRandomItemRes] = []
@export var max_spawn_count := 1
@export var preview_spawn_index := 0

# @override
# @impure
func spawn(parent_node: Node):
	if random_spawns.is_empty():
		return null
	var main_node := RkMain.get_main_node(parent_node)
	var spawn_count := 0
	for random_spawn in random_spawns:
		if random_spawn.probability > main_node.rng.randf():
			spawn_count += 1
			random_spawn.content.spawn(parent_node)
		if spawn_count >= max_spawn_count:
			break
	return null

# @override
# @impure
func spawn_preview(parent_node: Node):
	return random_spawns[preview_spawn_index].content.spawn_preview(parent_node)
