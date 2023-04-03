extends Node2D
class_name RkDecor

const debris_scene := preload("res://src/items/decors/debris.tscn")

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _life_points: float, _instigator: Object):
	var debris := debris_scene.instantiate()
	debris.position = position
	get_parent().add_child(debris)
	queue_free()
