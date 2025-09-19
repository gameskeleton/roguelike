@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkLifePointsSystem

enum DmgType {
	none = 0,
	#
	fire = 1,
	roll = 2,
	slide = 4,
	world = 8,
	physical = 16,
}

signal damage_taken(damage: float, from_source: Node, from_instigator: Node)
signal life_points_changed(life_points: float, life_points_ratio: float, life_points_previous: float)

const NO_DAMAGE := -1.0

@export_group("Invincible")
@export var invincible := 0
@export var prevent_take_damage_until_next_frame := 0.0

@export_group("Damage multipliers", "damage_multiplier")
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_roll := 1.0
@export var damage_multiplier_slide := 1.0
@export var damage_multiplier_world := 1.0
@export var damage_multiplier_physical := 1.0

var life_points := RkRpgFloat.create(10.0, 0.0, 10.0)
var last_damage := NO_DAMAGE
var last_damage_type := DmgType.none
var last_damage_source: Node
var last_damage_instigator: Node

# _process makes sure to clear the prevent_take_damage_until_next_frame flag.
# @impure
func _process(_delta: float):
	prevent_take_damage_until_next_frame = false

# take_damage reduces the life points by the amount of damage with respect to damage type multipliers.
# @impure
func take_damage(damage: float, damage_type := DmgType.none, from_source: Node = null, from_instigator: Node = null) -> float:
	assert(damage >= 0.0, "damage must be positive")
	if invincible > 0 or prevent_take_damage_until_next_frame:
		return NO_DAMAGE
	var damage_multiplier := 1.0
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.fire): damage_multiplier *= damage_multiplier_fire
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.roll): damage_multiplier *= damage_multiplier_roll
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.slide): damage_multiplier *= damage_multiplier_slide
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.world): damage_multiplier *= damage_multiplier_world
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.physical): damage_multiplier *= damage_multiplier_physical
	var scaled_damage := damage * damage_multiplier
	var life_points_previous := life_points.value
	if scaled_damage <= 0.0:
		return NO_DAMAGE
	last_damage = scaled_damage
	last_damage_type = damage_type
	last_damage_source = from_source
	last_damage_instigator = from_instigator
	prevent_take_damage_until_next_frame = true
	damage_taken.emit(life_points.sub(scaled_damage), from_source, from_instigator)
	life_points_changed.emit(life_points.value, life_points.ratio, life_points_previous)
	return scaled_damage

# has_lethal_damage returns true if our life points are lower or equal than zero.
# @pure
func has_lethal_damage() -> bool:
	return life_points.value <= 0.0

# is_damage_type returns true if the given individual_damage_type is included in the given damage_type.
# @pure
static func is_damage_type(damage_type: DmgType, individual_damage_type: DmgType) -> bool:
	return damage_type & individual_damage_type == individual_damage_type

# find_system_node returns the life points system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkLifePointsSystem:
	var system := node.get_node_or_null("Systems/LifePoints")
	if system is RkLifePointsSystem:
		return system as RkLifePointsSystem
	return null
