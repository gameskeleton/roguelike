@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkStaminaSystem

var stamina := RkAdvFloat.new(10.0)
var regeneration := RkAdvFloat.new(5.0, 5.0, true)
var regeneration_delay := RkAdvFloat.new(1.25, 1.25, true)

var _regeneration_delay := 0.0

# _process regenerates the stamina if the regen is not blocked.
# @impure
func _process(delta: float):
	if _regeneration_delay > 0.0:
		_regeneration_delay = maxf(0.0, _regeneration_delay - delta)
		if _regeneration_delay > 0.0:
			return
	stamina.add(delta * regeneration.current_value)

# has_enough returns true if the object has enough stamina left.
# @pure
func has_enough(amount: float) -> bool:
	return stamina.current_value >= amount

# consume reduces the stamina by the specified amount, if there is not enough the stamina will be zeroed.
# @impure
func consume(amount: float):
	stamina.sub(amount)
	_regeneration_delay = regeneration_delay.current_value

# try_consume returns true if the object has enough stamina left and will consume that amount if it does.
# @impure
func try_consume(amount: float) -> bool:
	if has_enough(amount):
		consume(amount)
		return true
	return false

# find_system_node returns the stamina system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkStaminaSystem:
	var system := node.get_node_or_null("Systems/Stamina")
	if system is RkStaminaSystem:
		return system
	return null
