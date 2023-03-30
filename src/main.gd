extends Control
class_name RkMain

const ROOM_SIZE := Vector2(512.0, 288.0)
const PLAYER_SIZE := Vector2(14.0, 28.0)
const ROOMS_DIRECTORY = "res://src/levels/rooms"
const ROOM_EXIT_VERTICAL_SIZE := Vector2(64.0, 64.0)
const ROOM_EXIT_HORIZONTAL_SIZE := Vector2(64.0, 64.0)

@export var map_room_scene: PackedScene = preload("res://src/gui/map_room.tscn")
@export var generate_dungeon := true

@onready var player_node: RkPlayer = $Game/Player
@onready var all_rooms_node: Node2D = $Game/AllRooms
@onready var player_camera_node: Camera2D = $Game/Player/Camera2D

@onready var gui_pause_control: Control = $CanvasLayer/Pause
@onready var gui_all_rooms_control: Control = $CanvasLayer/Pause/AllMapRooms

var generator := RkDungeonGenerator.new()
var current_room := Vector2()

func _ready():
	if generate_dungeon:
		_generate_dungeon_loop()
	_restrict_camera()
	player_camera_node.reset_smoothing()

func _process(delta: float):
	# pause
	if Input.is_action_just_pressed("player_pause"):
		var new_paused := not get_tree().paused
		get_tree().paused = new_paused
		gui_pause_control.visible = new_paused
	# gui update
	$CanvasLayer/State.text = player_node.fsm.current_state_node.name
	$CanvasLayer/StaminaMeter.progress = move_toward($CanvasLayer/StaminaMeter.progress, player_node.get_stamina(), delta)
	# room camera
	current_room.x = floor(player_node.position.x / ROOM_SIZE.x)
	current_room.y = floor(player_node.position.y / ROOM_SIZE.y)
	_restrict_camera()

func _restrict_camera():
	player_camera_node.limit_top = int(current_room.y * ROOM_SIZE.y)
	player_camera_node.limit_left = int(current_room.x * ROOM_SIZE.x)
	player_camera_node.limit_right = int((current_room.x + 1) * ROOM_SIZE.x)
	player_camera_node.limit_bottom = int((current_room.y + 1) * ROOM_SIZE.y)

func _generate_dungeon() -> bool:
	# clear rooms
	for room_node in all_rooms_node.get_children():
		all_rooms_node.remove_child(room_node)
		room_node.queue_free()
	for map_room_control in gui_all_rooms_control.get_children():
		gui_all_rooms_control.remove_child(map_room_control)
		map_room_control.queue_free()
	# load room scenes
	var dir := DirAccess.open(ROOMS_DIRECTORY)
	var room_scenes := {}
	for room_scenes_dir in dir.get_directories():
		dir.change_dir(ROOMS_DIRECTORY + "/" + room_scenes_dir)
		for room_scene_filename in dir.get_files():
			var room_scene: PackedScene = load(ROOMS_DIRECTORY + "/" + room_scenes_dir + "/" + room_scene_filename)
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
	generator.start = 45
	generator.min_rooms = 6
	generator.max_rooms = 10
	var dungeon := generator.next()
	var room_nodes: Array[RkRoom] = []
	# loop over each cell and create a room
	for i in dungeon.size():
		var x := (i % 10) - 1
		var y: int = (ceil(i / 10.0)) - 1
		var cell := dungeon[i]
		var cell_exits := 0
		if cell == 1:
			if dungeon[i - 1]: cell_exits |= RkRoom.Exit.left
			if dungeon[i + 1]: cell_exits |= RkRoom.Exit.right
			if dungeon[i - 10]: cell_exits |= RkRoom.Exit.up
			if dungeon[i + 10]: cell_exits |= RkRoom.Exit.down
			if room_scenes.has(cell_exits):
				# create dungeon room node
				var room_node: Node2D = (room_scenes[cell_exits] as Array[PackedScene]).pick_random().instantiate()
				room_node.position.x = x * ROOM_SIZE.x
				room_node.position.y = y * ROOM_SIZE.y
				all_rooms_node.add_child(room_node)
				room_node.owner = all_rooms_node
				room_nodes.push_back(room_node)
				# create pause map room control
				var map_margin := Vector2(2.0, 2.0)
				var map_spacing := Vector2(2.0, 2.0)
				var room_map_pos := Vector2(
					map_margin.x + (x * RkMapRoom.MAP_ROOM_SIZE.x) + (x * map_spacing.x),
					map_margin.y + (y * RkMapRoom.MAP_ROOM_SIZE.y) + (y * map_spacing.y)
				)
				var map_room_control: RkMapRoom = map_room_scene.instantiate()
				gui_all_rooms_control.add_child(map_room_control)
				map_room_control.set_position(room_map_pos)
				map_room_control.owner = gui_all_rooms_control
				map_room_control.room_node = room_node
			else:
				print("room with ", cell_exits, "exits does not exist...")
				return false
	# position player
	var start_room_node: RkRoom = room_nodes.pick_random()
	current_room = start_room_node.position / ROOM_SIZE
	player_node.position = Vector2(current_room.x * ROOM_SIZE.x + start_room_node.player_spawn.x, current_room.y * ROOM_SIZE.y + start_room_node.player_spawn.y)
	return true

func _generate_dungeon_loop():
	while not _generate_dungeon():
		pass

func _on_magic_slot_button_pressed():
	_generate_dungeon_loop()
	$CanvasLayer/MagicSlot.release_focus()
