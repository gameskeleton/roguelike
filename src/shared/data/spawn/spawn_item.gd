@tool
extends RkSpawnRes
class_name RkSpawnItemRes

const PICKUP_ITEM_SCENE: PackedScene = preload("res://src/objects/pickups/item.tscn")

@export var item: RkItemRes
@export var expulse_strength := 200.0
@export var expulse_direction := Vector2.UP

# @override
# @impure
func spawn(parent_node: Node) -> Node:
	if not item:
		return null
	var pickup_item_node: RkPickupItem = PICKUP_ITEM_SCENE.instantiate()
	pickup_item_node.item = item
	pickup_item_node.apply_central_impulse(expulse_direction * expulse_strength)
	parent_node.add_child(pickup_item_node)
	return pickup_item_node
