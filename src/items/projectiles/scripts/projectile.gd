extends Node2D
class_name RkProjectile

@export var speed := 160.0
@export var damage := 1.0
@export var direction := Vector2.LEFT
@export var damage_type := RkLifePoints.DmgType.none

@onready var attack_detector: Area2D = $AttackDetector

# @impure
func _ready():
	await get_tree().create_timer(4.0, false).timeout
	destroy_projectile(false)

# @impure
func _process(delta: float):
	position += direction * speed * delta

# @impure
func destroy_projectile(force := false):
	if force:
		queue_free()
	# TODO: nice animation
	attack_detector.monitoring = false
	attack_detector.monitorable = false
	queue_free()

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node):
	destroy_projectile()

# @signal
# @impure
func _on_attack_detector_body_entered(body: Node2D):
	if body is RkPlayer:
		body.life_points.take_damage(damage, damage_type, self, owner)

# @signal
# @impure
func _on_room_notifier_2d_room_leave():
	destroy_projectile(true)


# @signal
# @impure
func _on_room_notifier_2d_player_leave():
	destroy_projectile(true)
