extends Node2D

@export var debris_scene: PackedScene

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node):
	RkPickupSpawner.try_spawn_coins(self, global_position, 1)
	if debris_scene:
		var debris: Node2D = debris_scene.instantiate()
		debris.position = position
		get_parent().add_child(debris)
	queue_free()
