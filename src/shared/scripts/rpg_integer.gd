class_name RkRpgInteger

var value := 0:
	get: return value
	set(new_value): value = clampi(new_value, min_value, max_value)
var min_value := 0
var max_value := 0

var ratio: float:
	get: return float(value) / float(max_value)

# @impure
func add(amount: int) -> int:
	var prev_value := value
	value += amount
	return prev_value - value

# @impure
func sub(amount: int) -> int:
	var prev_value := value
	value -= amount
	return prev_value - value

# @impure
func deplete():
	value = min_value

# @impure
func resplenish():
	value = max_value

# @pure
static func create(in_value: int, in_min_value: int, in_max_value: int) -> RkRpgInteger:
	var rpg_integer := RkRpgInteger.new()
	rpg_integer.min_value = in_min_value
	rpg_integer.max_value = in_max_value
	rpg_integer.value = in_value
	return rpg_integer
