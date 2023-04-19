extends Node2D
class_name RkDecor

const DEBRIS_SCENE := preload("res://src/items/decors/debris.tscn")

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node):
	RkPickupSpawner.try_spawn_coins(self, global_position, 1)
	var debris := DEBRIS_SCENE.instantiate()
	debris.position = position
	get_parent().add_child(debris)
	queue_free()
