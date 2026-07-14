@tool
extends EditorScript

var _errors := 0
var _scenes := 0
var _teleporters := 0

# @impure
func _run() -> void:
	_errors = 0
	_teleporters = 0
	_scenes = 0
	for scene_path in _find_scenes("res://"):
		_check_scene(scene_path)
	print("---")
	print("checked %d teleporter(s) across %d scene(s): %d error(s)" % [_teleporters, _scenes, _errors])
	print("---")

# @impure
func _report(scene_path: String, teleporter: RkTeleporter, message: String) -> void:
	_errors += 1
	printerr("%s: teleporter \"%s\": %s" % [scene_path, teleporter.id, message])

# @pure
func _find_scenes(dir: String) -> Array[String]:
	var scenes: Array[String] = []
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() == "tscn":
			scenes.append(dir.path_join(file))
	for child_directory in DirAccess.get_directories_at(dir):
		scenes.append_array(_find_scenes(dir.path_join(child_directory)))
	return scenes

# @impure
func _check_scene(scene_path: String) -> void:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		return
	var root := packed.instantiate()
	var teleporters := _collect_teleporters(root)
	if not teleporters.is_empty():
		_scenes += 1
	var seen_ids: Dictionary[StringName, bool] = {}
	for teleporter in teleporters:
		_teleporters += 1
		if seen_ids.has(teleporter.id):
			_report(scene_path, teleporter, "duplicate id \"%s\"" % [teleporter.id])
		seen_ids[teleporter.id] = true
		for warning in teleporter.target.get_configuration_warnings(teleporter):
			_report(scene_path, teleporter, warning)
	root.free()

# @pure
func _collect_teleporters(node: Node) -> Array[RkTeleporter]:
	var teleporters: Array[RkTeleporter] = []
	if node is RkTeleporter:
		teleporters.push_back(node)
	for child in node.get_children():
		teleporters.append_array(_collect_teleporters(child))
	return teleporters
