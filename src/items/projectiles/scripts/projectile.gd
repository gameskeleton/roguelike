extends Node2D
class_name RkProjectile

@export var speed := 160.0
@export var direction := Vector2.LEFT

# @impure
func _ready():
	await get_tree().create_timer(4.0).timeout
	destroy_projectile(false)

# @impure
func _process(delta: float):
	position += direction * speed * delta

# @signal
# @impure
func _on_player_leave_room():
	destroy_projectile(true)

# @signal
# @impure
func _on_projectile_leave_room():
	destroy_projectile(true)

# @impure
func destroy_projectile(force := false):
	if force:
		queue_free()
	# TODO: nice animation
	queue_free()
