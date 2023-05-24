@tool
extends RkSpawnRes
class_name RkSpawnExperienceRes

@export var expulse_cone := 35.0
@export var expulse_strength := Vector2(180.0, 200.0)
@export var expulse_direction := Vector2.UP

# @override
# @impure
func spawn(parent_node: Node, global_position: Vector2) -> Node:
	return RkObjectSpawner.spawn_experience(parent_node, global_position + Vector2(0, -8.0)).fly(expulse_direction, expulse_cone, expulse_strength)

# @override
# @impure
func spawn_preview(parent_node: Node, global_position: Vector2) -> Node:
	return RkObjectSpawner.spawn_experience(parent_node, global_position + Vector2(0, -8.0))
