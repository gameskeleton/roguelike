extends Control
class_name RkMain

enum State { game, pause, level_up, game_over }

@export var debug_start_room_scene: PackedScene
@export var debug_start_room_grid_pos := Vector2i(1, 1)

@export_group("Nodes")
@export var player_node: RkPlayer
@export var all_rooms_node: Node2D
@export var player_camera_node: Camera2D
@export var object_spawner_node: RkObjectSpawner

@export var level_up_label: RichTextLabel
@export var level_up_animation_player: AnimationPlayer
@export var level_up_audio_stream_player: AudioStreamPlayer

@export var picked_up_label: RichTextLabel
@export var picked_up_animation_player: AnimationPlayer
@export var picked_up_audio_stream_player: AudioStreamPlayer

static var _main_node: RkMain = null

signal room_enter(room_node: RkRoom) # emitted when the player enters a new room.
signal room_leave(room_node: RkRoom) # emitted when the player leaves the current room and will be emitted before the next room_enter.

var rng := RandomNumberGenerator.new()
var spawn_rng := RandomNumberGenerator.new()

var state := State.game
var current_room_node: RkRoom # the room node the player is in.
var previous_room_node: RkRoom # the previous room node the player was in.
var player_node_position: Vector2 :
	get: return player_node.position + Vector2(0.0, -RkPlayer.SIZE.y * 0.5)

var _generator := RkDungeonGenerator.new()

# @impure
func _init():
	RkMain._main_node = self

# @impure
func _ready():
	# load debug start room scene or generate a new dungeon
	if debug_start_room_scene:
		_clear_rooms()
		var start_room_node := _instantiate_room(debug_start_room_scene, debug_start_room_grid_pos, 0)
		_enter_room(start_room_node)
		player_node.position = Vector2(debug_start_room_grid_pos.x * RkRoom.ROOM_SIZE.x + start_room_node.player_spawn.x, debug_start_room_grid_pos.y * RkRoom.ROOM_SIZE.y + start_room_node.player_spawn.y)
	else:
		_generate_dungeon()
	# setup death animation
	player_node.death.connect(func():
		state = State.game_over
		var tween := create_tween()
		tween.tween_property($CanvasModulate, "color", Color8(0, 0, 0), 1.0)
		tween.parallel().tween_property($AudioStreamPlayer, "volume_db", -80.0, 1.0)
		tween.parallel().tween_callback($DeathAudioStreamPlayer.play).set_delay(0.1)
		tween.tween_property($Game, "modulate", Color8(0, 0, 0), 2.0).set_delay(5.0)
	)
	# setup level up animation
	player_node.level_system.level_up.connect(func(_level: int):
		if state == State.game:
			state = State.level_up
			level_up_animation_player.play("level_up!")
		level_up_audio_stream_player.play()
	)
	# limit camera
	_limit_camera_to_room()
	player_camera_node.reset_smoothing()

# @impure
func _process(delta: float):
	_process_debug()
	match state:
		State.game: _process_game(delta)
		State.pause: _process_pause(delta)
		State.level_up: _process_level_up()
		State.game_over: _process_game_over()

# @impure
func _process_game(_delta: float):
	# pause game
	if Input.is_action_just_pressed("player_pause"):
		get_tree().paused = true
		state = State.pause
	# room and camera
	var player_grid_pos := Vector2i(
		floor(player_node_position.x / RkRoom.ROOM_SIZE.x),
		floor(player_node_position.y / RkRoom.ROOM_SIZE.y)
	)
	if player_grid_pos != current_room_node.get_grid_pos():
		var room_node_at_player_grid_pos := _get_room_node(player_grid_pos)
		if current_room_node != room_node_at_player_grid_pos:
			_leave_room(current_room_node)
			_enter_room(room_node_at_player_grid_pos)
			_limit_camera_to_room()

# @impure
func _process_debug():
	if player_node.dead:
		return
	if Input.is_action_just_pressed("ui_home"):
		_on_magic_slot_pressed()
	if Input.is_action_just_pressed("ui_page_up"):
		player_node.level_system.earn_experience(ceili(player_node.level_system.experience_required_to_level_up / 10.0))
	if Input.is_action_just_pressed("ui_page_down"):
		player_node.life_points_system.invincibility_delay = 0.0
		player_node.life_points_system.take_damage(ceilf(player_node.life_points_system.life_points.max_value / 10.0))

# @impure
func _process_pause(_delta: float):
	# resume game
	if Input.is_action_just_pressed("player_pause"):
		get_tree().paused = false
		state = State.game

# @impure
func _process_level_up():
	if not level_up_animation_player.is_playing():
		get_tree().paused = false
		state = State.game

# @impure
func _process_game_over():
	# reset
	if Input.is_key_pressed(KEY_ENTER):
		get_tree().reload_current_scene()
	# room and camera
	var player_grid_pos := Vector2i(
		floor(player_node_position.x / RkRoom.ROOM_SIZE.x),
		floor(player_node_position.y / RkRoom.ROOM_SIZE.y)
	)
	if player_grid_pos != current_room_node.get_grid_pos():
		var room_node_at_player_grid_pos := _get_room_node(player_grid_pos)
		if current_room_node != room_node_at_player_grid_pos:
			_leave_room(current_room_node)
			_enter_room(room_node_at_player_grid_pos)
			_limit_camera_to_room()

# @pure
static func get_main_node() -> RkMain:
	return _main_node

###
# Room
###

# room_pos transforms the given position in room position.
# @pure
func room_pos(global_pos: Vector2) -> Vector2:
	return global_pos - current_room_node.global_position

# has_corner_tile returns true if there is a corner tile at the given position.
# @pure
func has_corner_tile(pos: Vector2) -> bool:
	return current_room_node.has_corner_tile(pos)

# get_corner_tile_pos returns the top-center position of the corner tile.
# calling this when has_corner_tile of the given position returned false will yield incorrect results.
# @pure
func get_corner_tile_pos(pos: Vector2) -> Vector2:
	return current_room_node.wall_tile_map_layer.map_to_local(current_room_node.wall_tile_map_layer.local_to_map(pos))

# @impure
func _enter_room(room_node := current_room_node):
	current_room_node = room_node
	current_room_node.enter()
	room_enter.emit(current_room_node)

# @impure
func _leave_room(room_node := current_room_node):
	previous_room_node = room_node
	room_leave.emit(previous_room_node)
	previous_room_node.leave()

# @impure
func _clear_rooms():
	for room_node in all_rooms_node.get_children():
		all_rooms_node.remove_child(room_node)
		room_node.queue_free()

# @impure
func _instantiate_room(room_scene: PackedScene, room_grid_pos: Vector2i, distance: int) -> RkRoom:
	var room_node: RkRoom = room_scene.instantiate()
	room_node.name = _get_room_node_name(room_grid_pos)
	room_node.distance = distance
	room_node.position = room_grid_pos * RkRoom.ROOM_SIZE
	all_rooms_node.add_child(room_node)
	room_node.owner = all_rooms_node
	room_node.leave()
	return room_node

# @pure
func _get_room_node(grid_pos: Vector2i) -> RkRoom:
	return all_rooms_node.find_child(_get_room_node_name(grid_pos))

# @pure
func _get_room_node_name(grid_pos: Vector2i) -> StringName:
	return "Room_%s_%s" % [grid_pos.x, grid_pos.y]

###
# Camera
###

# @impure
func _limit_camera_to_room():
	var current_room_grid_pos := current_room_node.get_grid_pos()
	player_camera_node.limit_top = int(current_room_grid_pos.y * RkRoom.ROOM_SIZE.y)
	player_camera_node.limit_left = int(current_room_grid_pos.x * RkRoom.ROOM_SIZE.x)
	player_camera_node.limit_right = int((current_room_grid_pos.x + 1) * RkRoom.ROOM_SIZE.x)
	player_camera_node.limit_bottom = int((current_room_grid_pos.y + 1) * RkRoom.ROOM_SIZE.y)

###
# Dungeon
###

# @impure
func _generate_dungeon():
	_clear_rooms()
	_generator.rng = rng
	_generator.start = Vector2i(1, 1)
	_generator.min_rooms = 12
	_generator.max_rooms = 12
	var dungeon := _generator.next()
	var room_nodes: Array[RkRoom] = []
	# loop over each cell and create a room
	for y in _generator.height:
		for x in _generator.width:
			var pos = Vector2i(x + 1, y + 1)
			var cell: int = dungeon[pos.y][pos.x]
			var distance := absi(x - _generator.start.x) + absi(y - _generator.start.y)
			var cell_exits := 0
			if cell == 1:
				if dungeon[pos.y][pos.x - 1]: cell_exits |= RkRoom.Exit.left
				if dungeon[pos.y][pos.x + 1]: cell_exits |= RkRoom.Exit.right
				if dungeon[pos.y - 1][pos.x]: cell_exits |= RkRoom.Exit.up
				if dungeon[pos.y + 1][pos.x]: cell_exits |= RkRoom.Exit.down
				if RkRoomList.ROOM_SCENES.has(cell_exits):
					# create dungeon room node
					var room_node := _instantiate_room(RkUtils.pick_random(RkRoomList.ROOM_SCENES[cell_exits], rng), Vector2i(x, y), distance)
					room_nodes.push_back(room_node)
				else:
					push_error("room %s does not exist..." % [RkRoom.generate_room_exits_name(cell_exits)])
					return
	# position player
	var start_room_node: RkRoom = _get_room_node(_generator.start)
	var start_room_grid_pos := start_room_node.get_grid_pos()
	_enter_room(start_room_node)
	player_node.position = Vector2(start_room_grid_pos.x * RkRoom.ROOM_SIZE.x + start_room_node.player_spawn.x, start_room_grid_pos.y * RkRoom.ROOM_SIZE.y + start_room_node.player_spawn.y)

###
# User interface
###

# @signal
# @impure
func _on_magic_slot_pressed():
	_generate_dungeon()
	_limit_camera_to_room()
