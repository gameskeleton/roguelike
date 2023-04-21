@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkGoldSystem

signal earned(amount: float)

var gold := RkAdvFloat.new(0.0, 9999.0)

# @impure
func earn(amount: float):
	assert(amount > 0, "amount of gold to earn must be strictly positive")
	earned.emit(gold.add(amount))

# @pure
func has_enough(amount: float) -> bool:
	return gold.current_value >= amount

# @impure
func consume(amount: float):
	gold.sub(amount)

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
