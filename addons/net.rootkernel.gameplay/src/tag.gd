extends Resource
class_name RkGameplayTag

# @pure
func get_tag_unique_name() -> String:
	return "%s" % [resource_path]
