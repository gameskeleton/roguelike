@tool
extends Node2D

@export var items: Array[RkRoomSpawnerResource] = []
@export var max_spawn_count := 1

var _spawn_count := 0
var _preview_item_node: Node
var _preview_item_index := 0

# @impure
func _ready():
	if Engine.is_editor_hint():
		return
	var main_node := RkMain.get_main_node(self)
	if not main_node:
		return
	for item in items:
		if main_node.rng.randf() <= item.probability:
			var item_node := item.scene.instantiate()
			add_child(item_node)
			item_node.owner = self
			_spawn_count += 1
			if item_node is Node2D:
				(item_node as Node2D).position = item.offset
			if _spawn_count >= max_spawn_count:
				break

# @impure
func _enter_tree():
	if not Engine.is_editor_hint():
		return
	if not items.is_empty():
		_spawn_preview()
	while true:
		await get_tree().create_timer(1.0).timeout
		if not items.is_empty():
			_spawn_preview()

# @impure
func _spawn_preview():
	if not Engine.is_editor_hint():
		return
	if _preview_item_node:
		remove_child(_preview_item_node)
		_preview_item_node.queue_free()
		_preview_item_node = null
	var item := items[_preview_item_index]
	if item.scene:
		_preview_item_node = item.scene.instantiate()
		add_child(_preview_item_node)
		if _preview_item_node is Node2D:
			(_preview_item_node as Node2D).position = item.offset
	_preview_item_index = (_preview_item_index + 1) % items.size()
