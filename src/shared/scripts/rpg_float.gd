class_name RkRpgFloat

var value := 0.0:
	get: return value
	set(new_value): value = clampf(new_value, min_value, max_value)
var value_earn_multiplier := 1.0

var min_value := 0.0:
	get: return (min_value_base - min_value_malus) * min_value_multiplier
var min_value_base := -INF:
	get: return min_value_base
	set(new_min_value_base):
		min_value_base = new_min_value_base
		value = clampf(value, min_value, max_value)
var min_value_malus := 0.0:
	get: return min_value_malus
	set(new_min_value_malus):
		min_value_malus = new_min_value_malus
		value = clampf(value, min_value, max_value)
var min_value_multiplier := 1.0:
	get: return min_value_multiplier
	set(new_min_value_multiplier):
		min_value_multiplier = new_min_value_multiplier
		value = clampf(value, min_value, max_value)

var max_value := 0.0:
	get: return (max_value_base + max_value_bonus) * max_value_multiplier
var max_value_base := +INF:
	get: return max_value_base
	set(new_max_value_base):
		var prev_max_value := max_value
		max_value_base = new_max_value_base
		var next_max_value := max_value
		if not is_inf(prev_max_value) and not is_inf(next_max_value):
			value = clampf(value * (next_max_value / prev_max_value), min_value, max_value)
		else:
			value = clampf(value, min_value, max_value)
var max_value_bonus := 0.0:
	get: return max_value_bonus
	set(new_max_value_bonus):
		var prev_max_value := max_value
		max_value_bonus = new_max_value_bonus
		var next_max_value := max_value
		if not is_inf(prev_max_value) and not is_inf(next_max_value):
			value = clampf(value * (next_max_value / prev_max_value), min_value, max_value)
		else:
			value = clampf(value, min_value, max_value)
var max_value_multiplier := 1.0:
	get: return max_value_multiplier
	set(new_max_value_multiplier):
		var prev_max_value := max_value
		max_value_multiplier = new_max_value_multiplier
		var next_max_value := max_value
		if not is_inf(prev_max_value) and not is_inf(next_max_value):
			value = clampf(value * (next_max_value / prev_max_value), min_value, max_value)
		else:
			value = clampf(value, min_value, max_value)

var ratio: float:
	get: return value / max_value
var lower_is_better := false

# @impure
func add(amount: float) -> float:
	var prev_value := value
	value += amount * value_earn_multiplier
	return prev_value - value

# @impure
func sub(amount: float, use_earn_multiplier := false) -> float:
	var prev_value := value
	value -= amount * (value_earn_multiplier if use_earn_multiplier else 1.0)
	return prev_value - value

# @impure
func deplete():
	value = min_value

# @impure
func resplenish():
	value = max_value

# @impure
func reset_modifiers():
	reset_min_malus()
	reset_max_bonus()
	value_earn_multiplier = 1.0

# @impure
func reset_min_malus():
	min_value_malus = 0.0
	min_value_multiplier = 1.0

# @impure
func reset_max_bonus():
	max_value_bonus = 0.0
	max_value_multiplier = 1.0

# @pure
static func create(in_value: float, in_min_value_base: float, in_max_value_base: float, in_lower_is_better := false) -> RkRpgFloat:
	var rpg_float := RkRpgFloat.new()
	rpg_float.lower_is_better = in_lower_is_better
	rpg_float.min_value_base = in_min_value_base
	rpg_float.max_value_base = in_max_value_base
	rpg_float.value = in_value
	return rpg_float

# @pure
static func create_with_min(in_value: float, in_min_value_base: float, in_lower_is_better := false) -> RkRpgFloat:
	var rpg_float := RkRpgFloat.new()
	rpg_float.lower_is_better = in_lower_is_better
	rpg_float.min_value_base = in_min_value_base
	rpg_float.value = in_value
	return rpg_float

# @pure
static func create_with_max(in_value: float, in_max_value_base: float, in_lower_is_better := false) -> RkRpgFloat:
	var rpg_float := RkRpgFloat.new()
	rpg_float.lower_is_better = in_lower_is_better
	rpg_float.max_value_base = in_max_value_base
	rpg_float.value = in_value
	return rpg_float
