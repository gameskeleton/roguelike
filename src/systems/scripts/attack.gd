@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkAttack

signal attacked(target_life_points: RkLifePoints, damage: float, damage_type: RkLifePoints.DmgType)

const NO_DAMAGE := -1.0

@export var source: Node
@export var instigator: Node
@export var force_base := 1.0
@export var force_bonus := 0.0

@export_group("Damage multipliers", "damage_multiplier")
@export var damage_multiplier_ice := 1.0
@export var damage_multiplier_roll := 1.0
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_physical := 1.0
@export var damage_multiplier_lightning := 1.0

var force: float :
	get: return (force_base + force_bonus)
var last_target: RkLifePoints
var last_damage := RkLifePoints.NO_DAMAGE
var last_damage_type := RkLifePoints.DmgType.none

# attack deals the given amount of damages to the given target.
# @impure
func attack(target: RkLifePoints, damage: float, damage_type: RkLifePoints.DmgType) -> float:
	var damage_multiplier := 1.0
	match damage_type:
		RkLifePoints.DmgType.ice: damage_multiplier = damage_multiplier_ice
		RkLifePoints.DmgType.roll: damage_multiplier = damage_multiplier_roll
		RkLifePoints.DmgType.fire: damage_multiplier = damage_multiplier_fire
		RkLifePoints.DmgType.physical: damage_multiplier = damage_multiplier_physical
		RkLifePoints.DmgType.lightning: damage_multiplier = damage_multiplier_lightning
	var scaled_damage := force * damage * damage_multiplier
	if target.take_damage(scaled_damage, damage_type, source, instigator) != RkLifePoints.NO_DAMAGE:
		last_target = target
		last_damage = scaled_damage
		last_damage_type = damage_type
		attacked.emit(target, scaled_damage, damage_type)
		return scaled_damage
	return NO_DAMAGE
