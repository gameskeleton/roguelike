@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkStaminaSystem

var stamina := RkAdvFloat.new(10.0)

@export_group("Regen")
@export var regen_speed := 10.0
@export var regen_blocked_when_consumed_for := 1.15

var _regen_blocked_for := 0.0

# _process regenerates the stamina if the regen is not blocked.
# @impure
func _process(delta: float):
	if _regen_blocked_for > 0.0:
		_regen_blocked_for = maxf(0.0, _regen_blocked_for - delta)
		if _regen_blocked_for > 0.0:
			return
	stamina.add(delta * regen_speed)

# get_ratio returns the ratio [0; 1] between stamina and max_stamina.
# @pure
func get_ratio() -> float:
	return stamina.get_ratio()

# has_enough returns true if the object has enough stamina left.
# @pure
func has_enough(amount: float) -> bool:
	return stamina.current_value >= amount

# consume reduces the stamina by the specified amount, if there is not enough the stamina will be zeroed.
# the optional parameter block_regen_for takes a number of seconds during which the stamina won't be regenerated.
# @impure
func consume(amount: float, block_regen_for := regen_blocked_when_consumed_for):
	stamina.sub(amount)
	_regen_blocked_for = block_regen_for

# try_consume returns true if the object has enough stamina left and will consume that amount if it does.
# the optional parameter block_regen_for takes a number of seconds during which the stamina won't be regenerated.
# @impure
func try_consume(amount: float, block_regen_for := regen_blocked_when_consumed_for) -> bool:
	if has_enough(amount):
		consume(amount, block_regen_for)
		return true
	return false

# find_system_node returns the stamina system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkStaminaSystem:
	var system := node.get_node_or_null("Systems/Stamina")
	if system is RkStaminaSystem:
		return system
	return null
