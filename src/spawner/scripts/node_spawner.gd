@tool
extends Node2D

@export var content: RkSpawnRes :
	get: return content
	set(new_content):
		if content and Engine.is_editor_hint():
			content.changed.disconnect(_spawn_preview)
		content = new_content
		if content and Engine.is_editor_hint():
			content.changed.connect(_spawn_preview)
		if Engine.is_editor_hint():
			_spawn_preview()

var _preview_spawn_node: Node

# @impure
func _ready():
	if Engine.is_editor_hint():
		return
	if content:
		content.spawn(self, global_position)

# @impure
func _spawn_preview():
	if _preview_spawn_node:
		remove_child(_preview_spawn_node)
		_preview_spawn_node.queue_free()
		_preview_spawn_node = null
	if content:
		_preview_spawn_node = content.spawn_preview(self, global_position)
