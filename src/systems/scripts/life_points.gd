@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkLifePoints

enum DmgType {
	none,
	world,
	#
	roll,
	physical,
	#
	ice,
	fire,
	lightning,
}

signal damage_taken(damage: float, source: Node, instigator: Node)

const NO_DAMAGE := -1.0

@export var life_points := 10.0
@export var max_life_points_base := 10.0
@export var max_life_points_bonus := 0.0

@export_group("Invincible")
@export var invincible := 0
@export var invincibility_delay := 0.0

@export_group("Damage multipliers", "damage_multiplier")
@export var damage_multiplier_world := 1.0
@export var damage_multiplier_ice := 1.0
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_physical := 1.0
@export var damage_multiplier_lightning := 1.0

var max_life_points: float :
	get: return (max_life_points_base + max_life_points_bonus)

var last_damage := NO_DAMAGE
var last_damage_type := DmgType.none
var last_damage_source: Node
var last_damage_instigator: Node

# _process reduces the invincibility delay.
# @impure
func _process(delta: float):
	invincibility_delay = max(0.0, invincibility_delay - delta)

# get_ratio returns ratio [0; 1] between life_points and max_life_points.
# @pure
func get_ratio() -> float:
	return life_points / max_life_points

# take_damage reduces the life points by the amount of damage with respect to damage type multipliers.
# @impure
func take_damage(damage: float, type := DmgType.none, source: Node = null, instigator: Node = null) -> float:
	assert(damage >= 0.0, "damage must be positive")
	if invincible > 0 or invincibility_delay > 0.0:
		return NO_DAMAGE
	var damage_multiplier := 1.0
	match type:
		DmgType.ice: damage_multiplier = damage_multiplier_ice
		DmgType.fire: damage_multiplier = damage_multiplier_fire
		DmgType.physical: damage_multiplier = damage_multiplier_physical
		DmgType.lightning: damage_multiplier = damage_multiplier_lightning
	var scaled_damage := damage * damage_multiplier
	life_points -= scaled_damage
	last_damage = scaled_damage
	last_damage_type = type
	last_damage_source = source
	last_damage_instigator = instigator
	damage_taken.emit(scaled_damage, source, instigator)
	return scaled_damage

# has_lethal_damage returns true if our life points are lower or equal than zero.
# @pure
func has_lethal_damage() -> bool:
	return life_points <= 0.0

# set_invincibility_delay refills the invincibility delay towards the given value.
# @impure
func set_invincibility_delay(delay: float):
	invincibility_delay = max(delay, invincibility_delay)

# find_life_points_in_node returns the first life points node in the given node.
# @pure
static func find_life_points_in_node(node: Node) -> RkLifePoints:
	var life_points_node := node.get_node("LifePoints")
	if life_points_node is RkLifePoints:
		return life_points_node
	return null
