@tool
class_name RkTeleportTargetSceneChange extends RkTeleportTarget

@export var target_id := &"":
	get: return target_id
	set(value):
		if target_id == value:
			return
		target_id = value
		emit_changed()
@export_file("*.tscn") var level_scene_path: String:
	get: return level_scene_path
	set(value):
		if level_scene_path == value:
			return
		level_scene_path = value
		emit_changed()

# teleport loads a new scene and moves the player to the target teleporter.
# @impure
func teleport(from: RkTeleporter, player_node: RkPlayer) -> void:
	var offset := from.offset_position(player_node.position)
	var main_node := RkMain.get_main_node()
	var level_node := (load(level_scene_path) as PackedScene).instantiate() as RkLevel
	var target_teleporter_node := from.find_teleporter_node(level_node, target_id)
	assert(target_teleporter_node != null, "%s not found in %s" % [target_id, level_scene_path])
	main_node.level_manager_node.set_current_level_node(level_node)
	player_node.teleport(target_teleporter_node.position - offset)

# get_configuration_warnings returns editor warnings for this target.
# @pure
func get_configuration_warnings(_from: RkTeleporter) -> PackedStringArray:
	var warnings := PackedStringArray()
	if target_id == null or target_id.is_empty():
		warnings.push_back("target_id must be set")
	if level_scene_path == null or level_scene_path.is_empty():
		warnings.push_back("level_scene_path must be set")
	elif not FileAccess.file_exists(level_scene_path):
		warnings.push_back("level_scene_path does not exist")
	return warnings
