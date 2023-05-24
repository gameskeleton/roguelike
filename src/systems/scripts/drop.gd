@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkDropSystem

@export var drop_content: RkSpawnRes

func drop(global_position: Vector2):
	if drop_content:
		drop_content.spawn(self, global_position)
