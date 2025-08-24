extends RefCounted
class_name RkGameplayEffectHandle

var tick := 0.0
var effect: RkGameplayEffect

# @impure
func _init(in_effect: RkGameplayEffect):
	effect = in_effect
