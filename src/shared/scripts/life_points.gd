@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkLifePoints

enum DmgType {
	none,
	world,
	#
	ice,
	fire,
	physical,
	lightning,
}

signal damage_taken(damage: float, life_points: float, instigator: Object)

@export var invincible := false
@export var life_points := 10.0
@export var max_life_points := 10.0

@export_group("Damage multipliers", "damage_multiplier")
@export var damage_multiplier_world := 1.0
@export var damage_multiplier_ice := 1.0
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_physical := 1.0
@export var damage_multiplier_lightning := 1.0

# set_max sets the maximum life points and resplenishes the life points.
# @impure
func set_max(amount: float):
	life_points = amount
	max_life_points = amount

# get_ratio returns ratio [0; 1] between life_points and max_life_points.
# @pure
func get_ratio() -> float:
	return life_points / max_life_points

# take_damage reduces the life points by the amount of damage with respect to damage type multipliers.
# @impure
func take_damage(damage: float, damage_type := DmgType.none, instigator: Object = null) -> bool:
	assert(damage >= 0.0, "damage must be positive")
	if invincible:
		return false
	var damage_multiplier := 1.0
	match damage_type:
		DmgType.ice: damage_multiplier = damage_multiplier_ice
		DmgType.fire: damage_multiplier = damage_multiplier_fire
		DmgType.physical: damage_multiplier = damage_multiplier_physical
		DmgType.lightning: damage_multiplier = damage_multiplier_lightning
	var total_damage := damage * damage_multiplier
	life_points -= total_damage
	damage_taken.emit(total_damage, life_points, instigator)
	return true

# has_lethal_damage returns true if our life points are lower or equal than zero.
# @pure
func has_lethal_damage() -> bool:
	return life_points <= 0.0
