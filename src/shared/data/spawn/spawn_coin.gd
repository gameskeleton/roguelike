@tool
extends RkSpawnRes
class_name RkSpawnCoinRes

@export var min_count := 2
@export var max_count := 5
@export var expulse_cone := 35.0
@export var expulse_strength := Vector2(180.0, 200.0)
@export var expulse_direction := Vector2.UP
@export var delay_in_secs_between_spawns := 0.05

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	var count := randi_range(min_count, max_count)
	var coin_pickup_node: RkPickupCoin
	for i in count:
		coin_pickup_node = RkObjectSpawner.spawn_coin(parent_node, RkUtils.node_global_position(parent_node) + Vector2(0, -8.0))
		coin_pickup_node.fly(expulse_direction, expulse_cone, expulse_strength)
		await parent_node.get_tree().create_timer(delay_in_secs_between_spawns, false).timeout
	return coin_pickup_node

# @override
# @impure
func spawn_preview(parent_node: Node) -> Node:
	return RkObjectSpawner.spawn_coin(parent_node, RkUtils.node_global_position(parent_node) + Vector2(0, -8.0))
