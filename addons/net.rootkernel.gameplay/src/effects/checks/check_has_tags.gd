extends RkGameplayEffectCheck
class_name RkGameplayEffectCheck_HasTags

@export var include_tags: Array[RkGameplayTag]
@export var exclude_tags: Array[RkGameplayTag]

# @pure
func _check(manager: RkGameplayManager) -> bool:
	return include_tags.all(func(tag: RkGameplayTag): manager.has_tag(tag)) and \
		   not exclude_tags.any(func(tag: RkGameplayTag): manager.has_tag(tag))
