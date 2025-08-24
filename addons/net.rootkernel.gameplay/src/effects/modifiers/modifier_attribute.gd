extends RkGameplayEffectModifier
class_name RkGameplayEffectModifier_ModifyAttribute

enum Operator {
	set,
	add,
	subtract,
	multiply,
	divide,
}

@export var attribute: RkGameplayAttribute
@export var operator: Operator
@export var operand: float

# @impure
func _modify(manager: RkGameplayManager):
	manager.set_attribute_base_value(attribute, operand)
