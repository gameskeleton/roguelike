@tool
class_name RkTeleportTargetCoordinate extends RkTeleportTarget

@export var target_position := Vector2.ZERO

# teleport moves the player to the given coordinate within the same scene.
# @impure
func teleport(from: RkTeleporter, player_node: RkPlayer) -> void:
	var offset := from.offset_position(player_node.position)
	player_node.teleport(target_position - offset)

# get_configuration_warnings returns editor warnings for this target.
# @pure
func get_configuration_warnings(_from: RkTeleporter) -> PackedStringArray:
	return PackedStringArray()
