extends Control
class_name RkMain

const ROOM_SIZE := Vector2(512.0, 288.0)
const PLAYER_SIZE := Vector2(14.0, 28.0)
const ROOMS_DIRECTORY = "res://src/levels/rooms"
const ROOM_EXIT_VERTICAL_SIZE := Vector2(64.0, 64.0)
const ROOM_EXIT_HORIZONTAL_SIZE := Vector2(64.0, 64.0)

@export var generate_dungeon := true

enum RoomExit {
	up = 0b0001,
	down = 0b0010,
	left = 0b0100,
	right = 0b1000
}

var generator: RkDungeonGenerator = load("res://src/utilities/dungeon_generator.gd").new()
var current_room := Vector2()

func _ready():
	if generate_dungeon:
		_generate_dungeon()
	_restrict_camera()
	$Player/Camera2D.reset_smoothing()

func _process(delta: float):
	# gui update
	$CanvasLayer/State.text = $Player.fsm.current_state_node.name
	$CanvasLayer/StaminaMeter.progress = move_toward($CanvasLayer/StaminaMeter.progress, $Player.get_stamina(), delta)
	# room camera
	current_room.x = floor($Player.position.x / ROOM_SIZE.x)
	current_room.y = floor($Player.position.y / ROOM_SIZE.y)
	_restrict_camera()

func _restrict_camera():
	$Player/Camera2D.limit_top = current_room.y * ROOM_SIZE.y
	$Player/Camera2D.limit_left = current_room.x * ROOM_SIZE.x
	$Player/Camera2D.limit_right = (current_room.x + 1) * ROOM_SIZE.x
	$Player/Camera2D.limit_bottom = (current_room.y + 1) * ROOM_SIZE.y

func _generate_dungeon():
	# clear
	for room_node in $Rooms.get_children():
		$Rooms.remove_child(room_node)
		room_node.queue_free()
	# load rooms
	var rooms_dir := DirAccess.open(ROOMS_DIRECTORY)
	var room_scenes := {}
	for room_scene_filename in rooms_dir.get_files():
		var room_exits := 0
		var room_scene: PackedScene = load(ROOMS_DIRECTORY + "/" + room_scene_filename)
		var room_scene_state := room_scene.get_state()
		for property_index in room_scene_state.get_node_property_count(0):
			match room_scene_state.get_node_property_name(0, property_index):
				"exit_up": room_exits |= RoomExit.up
				"exit_down": room_exits |= RoomExit.down
				"exit_left": room_exits |= RoomExit.left
				"exit_right": room_exits |= RoomExit.right
		if room_scenes.has(room_exits):
			room_scenes[room_exits].append(room_scene)
		else:
			room_scenes[room_exits] = [room_scene]
	# generate dungeon
	generator.rng.randomize()
	generator.start = 45
	var spawns: Array[Vector2] = []
	var dungeon := generator.next()
	for i in dungeon.size():
		var x := (i % 10) - 1
		var y: int = (ceil(i / 10.0)) - 1
		var cell := dungeon[i]
		var cell_exits := 0
		if cell == 1:
			if dungeon[i - 1]: cell_exits |= RoomExit.left
			if dungeon[i + 1]: cell_exits |= RoomExit.right
			if dungeon[i - 10]: cell_exits |= RoomExit.up
			if dungeon[i + 10]: cell_exits |= RoomExit.down
			if room_scenes.has(cell_exits):
				var room_node: Node2D = (room_scenes[cell_exits] as Array[PackedScene]).pick_random().instantiate()
				spawns.push_back(Vector2(x, y))
				room_node.position.x = x * ROOM_SIZE.x
				room_node.position.y = y * ROOM_SIZE.y
				$Rooms.add_child(room_node)
	# position player
	current_room = spawns.pick_random()
	$Player.position = Vector2(current_room.x * ROOM_SIZE.x + ROOM_SIZE.x / 2, current_room.y * ROOM_SIZE.y + ROOM_SIZE.y / 2)
