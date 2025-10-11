@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkAttackSystem

signal attacked(target_life_points: RkLifePointsSystem, damage: float, damage_type: RkLifePointsSystem.DmgType)

const NO_DAMAGE := -1.0

var force := RkRpgSimpleFloat.create(1.0)
var defence := RkRpgSimpleFloat.create(1.0)

@export var source: Node
@export var instigator: Node

@export_group(&"Damage multipliers", "damage_multiplier")
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_roll := 1.0
@export var damage_multiplier_world := 1.0
@export var damage_multiplier_slide := 1.0
@export var damage_multiplier_physical := 1.0

var last_target: RkLifePointsSystem
var last_damage := RkLifePointsSystem.NO_DAMAGE
var last_damage_type := RkLifePointsSystem.DmgType.none

# attack deals the given amount of damages to the given target.
# @impure
func attack(target: RkLifePointsSystem, damage: float, damage_type: RkLifePointsSystem.DmgType, damage_source := source, damage_instigator := instigator) -> float:
	var damage_multiplier := 1.0
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.fire): damage_multiplier *= damage_multiplier_fire
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.roll): damage_multiplier *= damage_multiplier_roll
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.slide): damage_multiplier *= damage_multiplier_slide
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.world): damage_multiplier *= damage_multiplier_world
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.physical): damage_multiplier *= damage_multiplier_physical
	var scaled_damage := force.value * damage * damage_multiplier
	var target_scaled_damage := target.take_damage(scaled_damage, damage_type, damage_source, damage_instigator)
	if target_scaled_damage != RkLifePointsSystem.NO_DAMAGE:
		last_target = target
		last_damage = target_scaled_damage
		last_damage_type = damage_type
		attacked.emit(target, target_scaled_damage, damage_type)
		return target_scaled_damage
	return NO_DAMAGE

# find_system_node returns the attack system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkAttackSystem:
	var system := node.get_node_or_null("Systems/Attack")
	if system is RkAttackSystem:
		return system as RkAttackSystem
	return null
