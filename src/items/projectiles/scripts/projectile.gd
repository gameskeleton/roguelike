extends Node
class_name RkProjectile

@export var damage := 1.0
@export var damage_type := RkLifePointsSystem.DmgType.fire

@onready var attack_hitbox := $AttackHitbox as Area2D
@onready var life_points_system := $Systems/LifePoints as RkLifePointsSystem

# @impure
func destroy_projectile(force := false):
	if force:
		queue_free()
	# TODO: nice animation
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	queue_free()

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node):
	destroy_projectile()

# @signal
# @impure
func _on_attack_hitbox_body_entered(body: Node2D):
	if body is RkPlayer:
		body.life_points_system.take_damage(damage, damage_type, self, owner)
