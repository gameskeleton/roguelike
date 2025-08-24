@tool
extends Resource
class_name RkGameplayEffect

@export var checks: Array[RkGameplayEffectCheck]
@export var modifiers: Array[RkGameplayEffectModifier]

@export var first_tick := true
@export var interval_ms := 0.0
@export var duration_ms := 0.0

# @pure
func get_effect_unique_name() -> String:
	return resource_path
