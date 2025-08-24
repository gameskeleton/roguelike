extends Node
class_name RkGameplayManager

@export var tags: Array[RkGameplayTag]
@export var effects: Array[RkGameplayEffect]
@export var attributes: Array[RkGameplayAttribute]

var effect_handles: Array[RkGameplayEffectHandle] = []
var attribute_base_values := {}

# @impure
func _ready():
	for effect in effects:
		apply_effect(effect)
	for attribute in attributes:
		attribute_base_values[attribute.get_attribute_unique_name()] = 0.0

# @pure
func has_tag(tag: RkGameplayTag) -> bool:
	return tags.has(tag)

# @pure
func apply_effect(effect: RkGameplayEffect) -> RkGameplayEffectHandle:
	var handle := RkGameplayEffectHandle.new(effect)
	var checked := true
	effect_handles.append(handle)
	for check in effect.checks:
		if not check._check(self):
			print("failed check")
			checked = false
			break
	if checked:
		for modifier in effect.modifiers:
			print("modifi")
			modifier._modify(self)
	return handle

# @pure
func has_attribute(attribute: RkGameplayAttribute) -> bool:
	return attributes.has(attribute)

# @pure
func get_attribute_value(attribute: RkGameplayAttribute) -> float:
	return 0.0

# @impure
func set_attribute_base_value(attribute: RkGameplayAttribute, base_value: float):
	assert(has_attribute(attribute))
	print("set_attribute_base_value(%s, %d)" % [attribute.get_attribute_unique_name(), base_value])
	attribute_base_values[attribute.get_attribute_unique_name()] = base_value
