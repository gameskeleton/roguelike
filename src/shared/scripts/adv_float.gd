class_name RkAdvFloat

var ratio: float :
	get: return current_value / max_value

var max_value: float :
	get: return (max_value_base + max_value_bonus) * max_value_multiplier
var max_value_base := +INF :
	get: return max_value_base
	set(value):
		var prev_max_value := max_value
		max_value_base = value
		var next_max_value := max_value
		current_value = clampf(current_value * (next_max_value / prev_max_value), 0.0, max_value)
var max_value_bonus := 0.0 :
	get: return max_value_bonus
	set(value):
		var prev_max_value := max_value
		max_value_bonus = value
		var next_max_value := max_value
		current_value = clampf(current_value * (next_max_value / prev_max_value), 0.0, max_value)
var max_value_multiplier := 1.0 :
	get: return max_value_multiplier
	set(value):
		var prev_max_value := max_value
		max_value_multiplier = value
		var next_max_value := max_value
		current_value = clampf(current_value * (next_max_value / prev_max_value), 0.0, max_value)

var single_value := false
var current_value := 0.0 :
	get:
		if single_value:
			return max_value
		return current_value
	set(value):
		current_value = clampf(value, 0.0, max_value)
var current_value_earn_multiplier := 1.0

# @impure
func _init(in_current_value: float, in_max_value_base := in_current_value, in_single_value := false):
	assert(in_current_value <= in_max_value_base, "current_value must be less than or equal to max_value_base")
	max_value_base = in_max_value_base
	current_value = in_current_value
	single_value = in_single_value

# @impure
func add(amount: float) -> float:
	var total_amount := amount * current_value_earn_multiplier
	current_value = current_value + total_amount
	return total_amount

# @impure
func sub(amount: float) -> float:
	var total_amount := amount * current_value_earn_multiplier
	current_value = current_value - total_amount
	return total_amount

# @impure
func resplenish():
	current_value = max_value

# @impure
func reset_bonus():
	max_value_bonus = 0.0
	max_value_multiplier = 1.0
	current_value_earn_multiplier = 1.0
