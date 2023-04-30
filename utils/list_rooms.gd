@tool
extends EditorScript

const ROOMS_DIRECTORY := "res://src/rooms/scenes"
const ROOM_LIST_SCRIPT_FILENAME := "res://src/rooms/scripts/room_list.gd"

# @impure
func _run() -> void:
	var dir := DirAccess.open(ROOMS_DIRECTORY)
	var room_scenes := {}
	# list all room scenes
	for room_scenes_dir in dir.get_directories():
		dir.change_dir(ROOMS_DIRECTORY + "/" + room_scenes_dir)
		for room_scene_filename in dir.get_files():
			var room_name := ROOMS_DIRECTORY + "/" + room_scenes_dir + "/" + room_scene_filename
			var room_scene: PackedScene = load(room_name)
			var room_exit_code := 0
			var room_scene_state := room_scene.get_state()
			for property_index in room_scene_state.get_node_property_count(0):
				match room_scene_state.get_node_property_name(0, property_index):
					"exit_up": room_exit_code |= RkRoom.Exit.up
					"exit_down": room_exit_code |= RkRoom.Exit.down
					"exit_left": room_exit_code |= RkRoom.Exit.left
					"exit_right": room_exit_code |= RkRoom.Exit.right
			if room_scenes.has(room_exit_code):
				room_scenes[room_exit_code].append(room_name)
			else:
				room_scenes[room_exit_code] = [room_name] as Array[String]
	var exit_codes := room_scenes.keys().duplicate()
	exit_codes.sort()
	# generate room list script
	var script := "class_name RkRoomList\n\nconst ROOM_SCENES = {\n"
	for exit_code in exit_codes:
		script += "\t%02d: [" % [exit_code]
		var room_preloads: Array[String] = []
		for room_name in room_scenes[exit_code] as Array[String]:
			room_preloads.push_back("preload(\"%s\")" % [room_name])
		script += ", ".join(room_preloads) + "],\n"
	script += "}\n"
	var file_access := FileAccess.open(ROOM_LIST_SCRIPT_FILENAME, FileAccess.WRITE_READ)
	file_access.store_string(script)
	file_access.flush()
	print("%s generated" % [ROOM_LIST_SCRIPT_FILENAME])
