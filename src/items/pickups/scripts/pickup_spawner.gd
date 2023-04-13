extends Node
class_name RkPickupSpawner

@export var spawn_node: Node

@onready var coin_pickup_scene: PackedScene = preload("res://src/items/pickups/coin.tscn")
@onready var experience_pickup_scene: PackedScene = preload("res://src/items/pickups/experience.tscn")

# @impure
func spawn_coins(position: Vector2, count := 1):
	for i in count:
		var coin_pickup_node: RkPickupCoin = coin_pickup_scene.instantiate()
		spawn_node.add_child(coin_pickup_node)
		coin_pickup_node.global_position = position

# @impure
func spawn_experiences(position: Vector2, count := 1):
	for i in count:
		var experience_pickup_node: RkPickupExperience = experience_pickup_scene.instantiate()
		spawn_node.add_child(experience_pickup_node)
		experience_pickup_node.global_position = position

# @impure
static func try_spawn_coins(from_node: Node, position: Vector2, count := 1) -> bool:
	var main_node := RkMain.get_main_node(from_node)
	if main_node:
		main_node.pickup_spawner_node.spawn_coins(position, count)
		return true
	return false

# @impure
static func try_spawn_experiences(from_node: Node, position: Vector2, count := 1) -> bool:
	var main_node := RkMain.get_main_node(from_node)
	if main_node:
		main_node.pickup_spawner_node.spawn_experiences(position, count)
		return true
	return false
