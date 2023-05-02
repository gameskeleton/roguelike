@tool
extends Node2D

const EDITOR_PREVIEW_DELAY := 1.0

@export var random_spawns: Array[RkRandomSpawnRes] = [] :
	get: return random_spawns
	set(new_random_spawns):
		random_spawns = new_random_spawns
		preview_item_index = preview_item_index
		_spawn_preview()
@export var max_spawn_count := 1
@export var preview_item_index := 0 :
	get: return preview_item_index
	set(new_preview_item_index):
		preview_item_index = clampi(new_preview_item_index, 0, max(0, random_spawns.size() - 1))
		_spawn_preview()

var _spawn_count := 0
var _preview_item_node: Node

# @impure
func _ready():
	if Engine.is_editor_hint():
		return
	var main_node := RkMain.get_main_node(self)
	if not main_node:
		return
	for random_spawn in random_spawns:
		if not random_spawn:
			continue
		if main_node.rng.randf() <= random_spawn.probability:
			random_spawn.spawn.spawn(self)
			_spawn_count += 1
			if _spawn_count >= max_spawn_count:
				break

# @impure
func _spawn_preview():
	if not Engine.is_editor_hint():
		return
	if random_spawns.is_empty():
		return
	if _preview_item_node:
		remove_child(_preview_item_node)
		_preview_item_node.queue_free()
		_preview_item_node = null
	if random_spawns[preview_item_index] and random_spawns[preview_item_index].spawn:
		_preview_item_node = random_spawns[preview_item_index].spawn.spawn_preview(self)
