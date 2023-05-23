@tool
extends Node2D

const EDITOR_PREVIEW_DELAY := 1.0

@export var random_spawn: RkSpawnRandomRes :
	get: return random_spawn
	set(new_random_spawn):
		random_spawn = new_random_spawn
		preview_item_index = preview_item_index
		_spawn_preview()
@export var preview_item_index := 0 :
	get: return preview_item_index
	set(new_preview_item_index):
		preview_item_index = clampi(new_preview_item_index, 0, max(0, random_spawn.random_spawns.size() - 1))
		_spawn_preview()

var _preview_item_node: Node

# @impure
func _ready():
	if Engine.is_editor_hint():
		return
	if random_spawn:
		random_spawn.spawn(self)

# @impure
func _spawn_preview():
	if not Engine.is_editor_hint():
		return
	if not random_spawn:
		return
	if _preview_item_node:
		remove_child(_preview_item_node)
		_preview_item_node.queue_free()
		_preview_item_node = null
	random_spawn.preview_spawn_index = preview_item_index
	_preview_item_node = random_spawn.spawn_preview(self)
