@tool
extends RkSpawnRes
class_name RkSpawnItemRes

@export var item: RkItemRes :
	get: return item
	set(new_item):
		item = new_item
		if Engine.is_editor_hint():
			emit_changed()
@export var expulse_cone := 35.0
@export var expulse_strength := Vector2(180.0, 200.0)
@export var expulse_direction := Vector2.UP

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	if item:
		return RkObjectSpawner.spawn_item(parent_node, global_position, item).fly(expulse_direction, expulse_cone, expulse_strength)
	return null

# @override
# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	if item:
		return RkObjectSpawner.spawn_item(parent_node, global_position, item)
	return null
