extends Control
class_name RkMain

const PLAYER_SIZE := Vector2(14.0, 28.0)
const PLAYER_DOT_SIZE := Vector2(4.0, 4.0)

@export var map_room_scene: PackedScene = preload("res://src/gui/map_room.tscn")
@export var generate_dungeon := true

@onready var player_node: RkPlayer = $Game/Player
@onready var all_rooms_node: Node2D = $Game/AllRooms
@onready var player_camera_node: Camera2D = $Game/Player/Camera2D

@onready var ui_pause_control: Control = $CanvasLayer/Pause
@onready var ui_all_rooms_control: Control = $CanvasLayer/Pause/AllMapRooms
@onready var ui_player_dot_color_rect: ColorRect = $CanvasLayer/Pause/PlayerDot

signal room_enter(room_node: RkRoom)
signal room_leave(room_node: RkRoom)

var generator := RkDungeonGenerator.new()
var current_room := Vector2()
var previous_room := Vector2()

func _ready():
	if generate_dungeon:
		_try_generate_dungeon()
	_enter_room()
	_restrict_camera()
	player_camera_node.reset_smoothing()

func _process(delta: float):
	# pause
	if Input.is_action_just_pressed("player_pause"):
		var new_paused := not get_tree().paused
		get_tree().paused = new_paused
		ui_pause_control.visible = new_paused
		ui_player_dot_color_rect.position = (player_node.position * (RkMapRoom.MAP_ROOM_SIZE / RkRoom.ROOM_SIZE)) - (PLAYER_DOT_SIZE / 2)
	# gui update
	$CanvasLayer/State.text = player_node.fsm.current_state_node.name
	$CanvasLayer/StaminaMeter.progress = move_toward($CanvasLayer/StaminaMeter.progress, player_node.get_stamina(), delta)
	# current room and camera
	_process_room()
	_restrict_camera()

static func get_main_node(from_node: Node) -> RkMain:
	return from_node.get_tree().root.get_node("/root/Main")

###
# Room
###

func _enter_room():
	room_enter.emit(_get_room_node(current_room))
	var map_room_control := _get_map_room_control(current_room)
	if map_room_control:
		map_room_control.discovered = true

func _leave_room():
	room_leave.emit(_get_room_node(previous_room))

func _process_room():
	var player_room := Vector2(
		floor(player_node.position.x / RkRoom.ROOM_SIZE.x),
		floor(player_node.position.y / RkRoom.ROOM_SIZE.y)
	)
	if player_room != current_room:
		previous_room = current_room
		current_room = player_room
		_leave_room()
		_enter_room()

func _get_room_node(pos: Vector2i) -> RkRoom:
	return all_rooms_node.find_child(_get_room_node_name(pos))

func _get_room_node_name(pos: Vector2i) -> StringName:
	return "Room_%s_%s" % [pos.x, pos.y]

func _get_map_room_control(pos: Vector2i) -> RkMapRoom:
	return ui_all_rooms_control.find_child(_get_map_room_control_name(pos))

func _get_map_room_control_name(pos: Vector2i) -> StringName:
	return "MapRoom_%s_%s" % [pos.x, pos.y]

###
# Camera
###

func _restrict_camera():
	player_camera_node.limit_top = int(current_room.y * RkRoom.ROOM_SIZE.y)
	player_camera_node.limit_left = int(current_room.x * RkRoom.ROOM_SIZE.x)
	player_camera_node.limit_right = int((current_room.x + 1) * RkRoom.ROOM_SIZE.x)
	player_camera_node.limit_bottom = int((current_room.y + 1) * RkRoom.ROOM_SIZE.y)

###
# Dungeon
###

func _generate_dungeon() -> bool:
	# clear rooms
	for room_node in all_rooms_node.get_children():
		all_rooms_node.remove_child(room_node)
		room_node.queue_free()
	for map_room_control in ui_all_rooms_control.get_children():
		ui_all_rooms_control.remove_child(map_room_control)
		map_room_control.queue_free()
	# load room scenes
	var dir := DirAccess.open(RkRoom.ROOMS_DIRECTORY)
	var room_scenes := {}
	for room_scenes_dir in dir.get_directories():
		dir.change_dir(RkRoom.ROOMS_DIRECTORY + "/" + room_scenes_dir)
		for room_scene_filename in dir.get_files():
			var room_scene: PackedScene = load(RkRoom.ROOMS_DIRECTORY + "/" + room_scenes_dir + "/" + room_scene_filename)
			var room_exits := 0
			var room_scene_state := room_scene.get_state()
			for property_index in room_scene_state.get_node_property_count(0):
				match room_scene_state.get_node_property_name(0, property_index):
					"exit_up": room_exits |= RkRoom.Exit.up
					"exit_down": room_exits |= RkRoom.Exit.down
					"exit_left": room_exits |= RkRoom.Exit.left
					"exit_right": room_exits |= RkRoom.Exit.right
			if room_scenes.has(room_exits):
				room_scenes[room_exits].append(room_scene)
			else:
				room_scenes[room_exits] = [room_scene]
	# generate dungeon
	generator.start = Vector2i(2, 2)
	generator.min_rooms = 12
	generator.max_rooms = 12
	var dungeon := generator.next()
	var room_nodes: Array[RkRoom] = []
	# loop over each cell and create a room
	for y in generator.height:
		for x in generator.width:
			var pos = Vector2i(x + 1, y + 1)
			var cell: int = dungeon[pos.y][pos.x]
			var cell_exits := 0
			if cell == 1:
				if dungeon[pos.y][pos.x - 1]: cell_exits |= RkRoom.Exit.left
				if dungeon[pos.y][pos.x + 1]: cell_exits |= RkRoom.Exit.right
				if dungeon[pos.y - 1][pos.x]: cell_exits |= RkRoom.Exit.up
				if dungeon[pos.y + 1][pos.x]: cell_exits |= RkRoom.Exit.down
				if room_scenes.has(cell_exits):
					# create dungeon room node
					var room_node: Node2D = (room_scenes[cell_exits] as Array[PackedScene]).pick_random().instantiate()
					room_node.name = _get_room_node_name(Vector2i(x, y))
					room_node.position.x = x * RkRoom.ROOM_SIZE.x
					room_node.position.y = y * RkRoom.ROOM_SIZE.y
					all_rooms_node.add_child(room_node)
					room_node.owner = all_rooms_node
					room_nodes.push_back(room_node)
					# create pause map room control
					var room_map_pos := Vector2(
						x * RkMapRoom.MAP_ROOM_SIZE.x,
						y * RkMapRoom.MAP_ROOM_SIZE.y
					)
					var map_room_control: RkMapRoom = map_room_scene.instantiate()
					map_room_control.name = _get_map_room_control_name(Vector2i(x, y))
					map_room_control.room_node = room_node
					map_room_control.set_position(room_map_pos)
					ui_all_rooms_control.add_child(map_room_control)
					map_room_control.owner = ui_all_rooms_control
				else:
					print("room with %d exits does not exist..." % [cell_exits])
					return false
	# position player
	var start_room_node: RkRoom = room_nodes.pick_random()
	current_room = start_room_node.position / RkRoom.ROOM_SIZE
	player_node.position = Vector2(current_room.x * RkRoom.ROOM_SIZE.x + start_room_node.player_spawn.x, current_room.y * RkRoom.ROOM_SIZE.y + start_room_node.player_spawn.y)
	return true

func _try_generate_dungeon():
	while not _generate_dungeon():
		pass

###
# User interface
###

func _on_magic_slot_button_pressed():
	_try_generate_dungeon()
	_enter_room()
	$CanvasLayer/MagicSlot.release_focus()
