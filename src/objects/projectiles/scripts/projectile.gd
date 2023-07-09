extends Node2D
class_name RkProjectile

@export var speed := 160.0
@export var damage := 1.0
@export var direction := Vector2.LEFT
@export var damage_type := RkLifePointsSystem.DmgType.none

@export_group("Nodes")
@export var attack_detector: Area2D
@export var life_points_system: RkLifePointsSystem

# @impure
func _ready():
	life_points_system.life_points.max_value_base = 1.0
	await get_tree().create_timer(4.0, false).timeout
	destroy_projectile(false)

# @impure
func _process(delta: float):
	position += direction * speed * delta

# @impure
func _leave_room(_room: RkRoom):
	destroy_projectile(true)

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
func _on_room_notifier_2d_room_leave():
	destroy_projectile(true)

# @signal
# @impure
func _on_attack_detector_body_entered(body: Node2D):
	if body is RkPlayer:
		body.life_points_system.take_damage(damage, damage_type, self, owner)
