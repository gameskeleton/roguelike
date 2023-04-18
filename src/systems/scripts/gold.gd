@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkGoldSystem

signal earned(amount: float)

@export var gold := 0.0
@export var max_gold := 9999.0
@export var earn_multiplier := 1.0

# @impure
func earn(amount: float):
	assert(amount > 0, "amount of gold to earn must be strictly positive")
	assert(earn_multiplier > 0, "earn multiplier must be strictly positive")
	var total_amount := amount * earn_multiplier
	gold = minf(gold + total_amount, max_gold)
	earned.emit(total_amount)

# @pure
func has_enough(amount: float) -> bool:
	return gold >= amount

# @impure
func consume(amount: float):
	gold = maxf(0, gold - amount)

# @impure
func try_consume(amount: float) -> bool:
	if has_enough(amount):
		consume(amount)
		return true
	return false

# find_system_node returns the gold system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkGoldSystem:
	var system := node.get_node_or_null("Systems/Gold")
	if system is RkGoldSystem:
		return system
	return null
