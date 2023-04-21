@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkLifePointsSystem

enum DmgType {
	none = 0,
	#
	fire = 1,
	roll = 2,
	world = 4,
	physical = 8,
}

signal damage_taken(damage: float, source: Node, instigator: Node)

const NO_DAMAGE := -1.0

var life_points := RkAdvFloat.new(10.0)

@export_group("Invincible")
@export var invincible := 0
@export var invincibility_delay := 0.0

@export_group("Damage multipliers", "damage_multiplier")
@export var damage_multiplier_fire := 1.0
@export var damage_multiplier_roll := 1.0
@export var damage_multiplier_world := 1.0
@export var damage_multiplier_physical := 1.0

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
	return life_points.get_ratio()

# take_damage reduces the life points by the amount of damage with respect to damage type multipliers.
# @impure
func take_damage(damage: float, damage_type := DmgType.none, source: Node = null, instigator: Node = null) -> float:
	assert(damage >= 0.0, "damage must be positive")
	if invincible > 0 or invincibility_delay > 0.0:
		return NO_DAMAGE
	var damage_multiplier := 1.0
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.fire): damage_multiplier *= damage_multiplier_fire
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.roll): damage_multiplier *= damage_multiplier_roll
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.world): damage_multiplier *= damage_multiplier_world
	if RkLifePointsSystem.is_damage_type(damage_type, RkLifePointsSystem.DmgType.physical): damage_multiplier *= damage_multiplier_physical
	var scaled_damage := damage * damage_multiplier
	last_damage = scaled_damage
	last_damage_type = damage_type
	last_damage_source = source
	last_damage_instigator = instigator
	damage_taken.emit(life_points.sub(scaled_damage), source, instigator)
	return scaled_damage

# has_lethal_damage returns true if our life points are lower or equal than zero.
# @pure
func has_lethal_damage() -> bool:
	return life_points.current_value <= 0.0

# set_invincibility_delay refills the invincibility delay towards the given value.
# @impure
func set_invincibility_delay(delay: float):
	invincibility_delay = max(delay, invincibility_delay)

# is_damage_type returns true if the given individual_damage_type is included in the given damage_type.
# @pure
static func is_damage_type(damage_type: DmgType, individual_damage_type: DmgType):
	return damage_type & individual_damage_type == individual_damage_type

# find_system_node returns the life points system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkLifePointsSystem:
	var system := node.get_node_or_null("Systems/LifePoints")
	if system is RkLifePointsSystem:
		return system
	return null
