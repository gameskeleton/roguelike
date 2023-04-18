@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkAttackSystem

signal attacked(target_life_points: RkLifePointsSystem, damage: float, damage_type: RkLifePointsSystem.DmgType)

const NO_DAMAGE := -1.0

@export var source: Node
@export var instigator: Node
@export var force_base := 1.0
@export var force_bonus := 0.0

@export_group("Damage multipliers", "damage_multiplier")
@export var damage_multiplier_ice := 1.0
@export var damage_multiplier_roll := 1.0
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_world := 1.0
@export var damage_multiplier_physical := 1.0
@export var damage_multiplier_lightning := 1.0

var force: float :
	get: return (force_base + force_bonus)
var last_target: RkLifePointsSystem
var last_damage := RkLifePointsSystem.NO_DAMAGE
var last_damage_type := RkLifePointsSystem.DmgType.none

# attack deals the given amount of damages to the given target.
# @impure
func attack(target: RkLifePointsSystem, damage: float, damage_type: RkLifePointsSystem.DmgType) -> float:
	var damage_multiplier := 1.0
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.ice): damage_multiplier *= damage_multiplier_ice
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.roll): damage_multiplier *= damage_multiplier_roll
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.fire): damage_multiplier *= damage_multiplier_fire
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.world): damage_multiplier *= damage_multiplier_world
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.physical): damage_multiplier *= damage_multiplier_physical
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.lightning): damage_multiplier *= damage_multiplier_lightning
	var scaled_damage := force * damage * damage_multiplier
	if target.take_damage(scaled_damage, damage_type, source, instigator) != RkLifePointsSystem.NO_DAMAGE:
		last_target = target
		last_damage = scaled_damage
		last_damage_type = damage_type
		attacked.emit(target, scaled_damage, damage_type)
		return scaled_damage
	return NO_DAMAGE
