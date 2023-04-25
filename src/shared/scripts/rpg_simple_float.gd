class_name RkRpgSimpleFloat

var value: float:
	get: return (value_base + value_bonus) * value_multiplier
var value_base := 0.0
var value_bonus := 0.0
var value_multiplier := 1.0
var value_earn_multiplier := 1.0

var lower_is_better := false

# @impure
func add(amount: float) -> float:
	var total_amount := amount * value_earn_multiplier
	value_base += total_amount
	return total_amount

# @impure
func sub(amount: float, use_earn_multiplier := false) -> float:
	var total_amount := amount * (value_earn_multiplier if use_earn_multiplier else 1.0)
	value_base -= total_amount
	return total_amount

# @impure
func reset_modifiers():
	value_bonus = 0.0
	value_multiplier = 1.0
	value_earn_multiplier = 1.0

# @pure
static func create(in_value_base: float, in_lower_is_better := false) -> RkRpgSimpleFloat:
	var rpg_simple_float := RkRpgSimpleFloat.new()
	rpg_simple_float.value_base = in_value_base
	rpg_simple_float.lower_is_better = in_lower_is_better
	return rpg_simple_float
