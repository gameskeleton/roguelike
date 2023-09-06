extends Node
class_name RkObjectSpawner

const COIN_PICKUP_SCENE: PackedScene = preload("res://src/items/pickups/coin.tscn")
const EXPERIENCE_PICKUP_SCENE: PackedScene = preload("res://src/items/pickups/experience.tscn")

@export var spawn_node: Node

# @impure
static func spawn_coin(from_node: Node, position: Vector2) -> RkPickupCoin:
	var main_node := RkMain.get_main_node()
	var coin_pickup_node := COIN_PICKUP_SCENE.instantiate() as RkPickupCoin
	(main_node.object_spawner_node.spawn_node if main_node else from_node).add_child(coin_pickup_node)
	coin_pickup_node.global_position = position
	return coin_pickup_node

# @impure
static func spawn_experience(from_node: Node, position: Vector2) -> RkPickupExperience:
	var main_node := RkMain.get_main_node()
	var experience_pickup_node := EXPERIENCE_PICKUP_SCENE.instantiate() as RkPickupExperience
	(main_node.object_spawner_node.spawn_node if main_node else from_node).add_child(experience_pickup_node)
	experience_pickup_node.global_position = position
	return experience_pickup_node
