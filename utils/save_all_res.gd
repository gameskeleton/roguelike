@tool
extends EditorScript

const RESOURCE_EXTENSIONS := ["tscn", "tres"]

var _files: Array[String] = []

# @impure
func _run() -> void:
	_files.clear()
	_add_files("res://")
	for file in _files:
		var res := load(file)
		if ResourceSaver.save(res) == OK:
			print("resource %s saved" % [file])

# @impure
func _add_files(dir: String):
	for child_file in DirAccess.get_files_at(dir):
		if RESOURCE_EXTENSIONS.has(child_file.get_extension()):
			_files.append(dir.path_join(child_file))
	for child_dir in DirAccess.get_directories_at(dir):
		_add_files(dir.path_join(child_dir))
