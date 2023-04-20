class_name RkAdvFloat

var current_value := 0.0 :
	get:
		if sync_max_to_current:
			return max_value
		return current_value
	set(value):
		current_value = clampf(value, 0.0, max_value)
var sync_max_to_current := false
var current_value_earn_multiplier := 1.0

var max_value: float :
	get: return (max_value_base + max_value_bonus) * max_value_multiplier
var max_value_base := +INF :
	get: return max_value_base
	set(value):
		max_value_base = value
		current_value = clampf(current_value, 0.0, max_value)
var max_value_bonus := 0.0 :
	get: return max_value_bonus
	set(value):
		max_value_bonus = value
		current_value = clampf(current_value, 0.0, max_value)
var max_value_multiplier := 1.0 :
	get: return max_value_multiplier
	set(value):
		max_value_multiplier = value
		current_value = clampf(current_value, 0.0, max_value)

# @impure
func _init(default_value: float, default_max_value := default_value, max_to_current := false):
	assert(default_value <= default_max_value, "default_value must be less than or equal to default_max_value")
	self.max_value_base = default_max_value
	self.current_value = default_value
	self.sync_max_to_current = max_to_current

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

# get_ratio returns the ratio [0; 1] between current_value and max_value.
# @pure
func get_ratio() -> float:
	return current_value / max_value
