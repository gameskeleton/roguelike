@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkGold

signal earn_gold(amount: int)

@export var gold := 0
@export var max_gold := 9999

# @impure
func earn(amount: int):
	assert(amount > 0, "amount of gold to earn must be strictly positive")
	gold = min(gold + amount, max_gold)
	earn_gold.emit(amount)

# @pure
func has_enough(amount: int) -> bool:
	return gold >= amount

# @impure
func consume(amount: int):
	gold = max(0, gold - amount)

# @impure
func try_consume(amount: int) -> bool:
	if has_enough(amount):
		consume(amount)
		return true
	return false

