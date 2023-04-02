extends Node2D
class_name RkProjectile

@export var speed := 160.0
@export var direction := Vector2.LEFT

func _ready():
	await get_tree().create_timer(4.0).timeout
	queue_free()

func _process(delta: float):
	position += direction * speed * delta
