@tool
extends RkSpawnRes
class_name RkSpawnCoinRes

const PICKUP_COIN_SCENE: PackedScene = preload("res://src/objects/pickups/coin.tscn")

@export var min_count := 1
@export var max_count := 1
@export var expulse_direction := Vector2.UP
@export var expulse_strength_min := 180.0
@export var expulse_strength_max := 200.0
@export var expulse_direction_cone := 35.0
@export var delay_in_secs_between_spawns := 0.05

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	var count := randi_range(min_count, max_count)
	var pickup_coin_node: RkPickupCoin
	for i in count:
		var strength := randf_range(expulse_strength_min, expulse_strength_max)
		var direction := expulse_direction.rotated(deg_to_rad(randf_range(-expulse_direction_cone * 0.5, +expulse_direction_cone * 0.5)))
		pickup_coin_node = PICKUP_COIN_SCENE.instantiate()
		pickup_coin_node.position = Vector2(0, -8.0)
		pickup_coin_node.apply_central_impulse(strength * direction)
		parent_node.add_child(pickup_coin_node)
		await parent_node.get_tree().create_timer(delay_in_secs_between_spawns, false).timeout
	return pickup_coin_node

# @override
# @impure
func spawn_preview(parent_node: Node) -> Node:
	var pickup_coin_node: RkPickupCoin = PICKUP_COIN_SCENE.instantiate()
	pickup_coin_node.position = Vector2(0, -8.0)
	parent_node.add_child(pickup_coin_node)
	return pickup_coin_node
