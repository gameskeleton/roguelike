@tool
extends Node2D

@export var items: Array[RkRoomSpawnerResource] = []
@export var max_spawn_count := 1

var _spawn_count := 0
var _preview_delay := 0.0
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
			if "direction" in item_node and item_node.direction is int:
				item_node.direction = item.direction
			if _spawn_count >= max_spawn_count:
				break

# @impure
func _process(delta):
	_preview_delay -= delta
	if _preview_delay <= 0.0:
		_preview_delay = 1.0
		_spawn_next_preview()

# @impure
func _enter_tree():
	set_process(Engine.is_editor_hint())

# @impure
func _exit_tree():
	set_process(false)

# @impure
func _spawn_next_preview():
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
		if "direction" in _preview_item_node and _preview_item_node.direction is int:
			_preview_item_node.direction = item.direction
	_preview_item_index = (_preview_item_index + 1) % items.size()
