@tool
class_name RkTeleportTargetBlank extends RkTeleportTarget

# teleport does nothing: this config marks a destination-only teleporter.
# @impure
func teleport(_from: RkTeleporter, _player_node: RkPlayer) -> void:
	pass

# get_configuration_warnings returns editor warnings for this target.
# @pure
func get_configuration_warnings(_from: RkTeleporter) -> PackedStringArray:
	return PackedStringArray()
