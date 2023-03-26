extends Node2D
class_name RkDecor

const debris_scene := preload("res://src/items/decors/debris.tscn")

func _roll(_player: RkPlayer):
	var debris := debris_scene.instantiate()
	debris.position = position
	get_parent().add_child(debris)
	queue_free()
