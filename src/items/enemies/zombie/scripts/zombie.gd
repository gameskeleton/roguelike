extends CharacterBody2D

const MAX_SPEED := 50.0
const ACCELERATION := 100.0

const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

var direction := 1.0

@export var damage := 3.0
@export var damage_type := RkLifePointsSystem.DmgType.physical

@export_group("Systems")
@export var attack_system: RkAttackSystem
@export var life_points_system: RkLifePointsSystem

# @impure
func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, MAX_SPEED * direction, delta * ACCELERATION)
	velocity.y = move_toward(velocity.y, GRAVITY_MAX_SPEED, delta * GRAVITY_ACCELERATION)
	move_and_slide()
	if is_on_wall():
		direction *= -1.0

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node) -> void:
	if life_points_system.has_lethal_damage():
		queue_free()

# @signal
# @impure
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	var target_life_points_system := RkLifePointsSystem.find_system_node(body)
	if target_life_points_system:
		attack_system.attack(target_life_points_system, damage, damage_type)
