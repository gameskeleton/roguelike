@tool
class_name RkTeleportTargetSameScene extends RkTeleportTarget

@export var target_id := &"":
	get: return target_id
	set(value):
		if target_id == value:
			return
		target_id = value
		emit_changed()

# teleport moves the player to the given teleporter within the same scene.
# @impure
func teleport(from: RkTeleporter, player_node: RkPlayer) -> void:
	var offset := from.offset_position(player_node.position)
	var level_node := RkMain.get_main_node().level_manager_node.level_node
	var target_teleporter_node := from.find_teleporter_node(level_node, target_id)
	player_node.teleport(target_teleporter_node.position - offset)

# get_configuration_warnings returns editor warnings for this target.
# @pure
func get_configuration_warnings(_from: RkTeleporter) -> PackedStringArray:
	var warnings := PackedStringArray()
	if target_id == null or target_id.is_empty():
		warnings.push_back("target_id must be set")
	return warnings
