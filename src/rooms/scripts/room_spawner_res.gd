extends Resource
class_name RkRoomSpawnerResource

@export var scene: PackedScene
@export var params := {}
@export var offset := Vector2.ZERO
@export var probability := 0.5
@export var distance_probability_modifier := 1.0
@export_range(-1, 1, 2) var direction := -1
