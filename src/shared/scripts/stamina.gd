@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkStamina

@export var stamina := 10.0
@export var max_stamina := 10.0
@export var regen_speed := 10.0
@export var regen_blocked_when_consumed_for := 1.5

var _regen_blocked_for := 0.0

# _process regenerates the stamina if the regen is not blocked.
# @impure
func _process(delta):
	if _regen_blocked_for > 0.0:
		_regen_blocked_for = max(0.0, _regen_blocked_for - delta)
		if _regen_blocked_for > 0.0:
			return
	stamina = clamp(stamina + delta * regen_speed, 0.0, max_stamina)

# set_max sets the maximum stamina and resplenishes the stamina.
# @impure
func set_max(amount: float):
	stamina = amount
	max_stamina = amount

# get_ratio returns the ratio [0; 1] between stamina and max_stamina.
# @pure
func get_ratio() -> float:
	return stamina / max_stamina

# has_enough returns true if the object has enough stamina left.
# @pure
func has_enough(amount: float) -> bool:
	return stamina >= amount

# consume reduces the stamina by the specified amount, if there is not enough the stamina will be zeroed.
# the optional parameter block_regen_for takes a number of seconds during which the stamina won't be regenerated.
# @impure
func consume(amount: float, block_regen_for := regen_blocked_when_consumed_for):
	stamina = clamp(stamina - amount, 0.0, max_stamina)
	_regen_blocked_for = block_regen_for

# try_consume returns true if the object has enough stamina left and will consume that amount if it does.
# the optional parameter block_regen_for takes a number of seconds during which the stamina won't be regenerated.
# @impure
func try_consume(amount: float, block_regen_for := regen_blocked_when_consumed_for) -> bool:
	if has_enough(amount):
		consume(amount, block_regen_for)
		return true
	return false
