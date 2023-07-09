extends Control
class_name RkMain

enum State { game, pause, level_up, game_over }

const MAP_ROOM_SCENE: PackedScene = preload("res://src/gui/map_room.tscn")

@export var map_revealed := false
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

@export var ui_game_control: Control
@export var ui_game_state_label: Label
@export var ui_game_stamina_meter: RkGuiProgressBar
@export var ui_game_magic_slot_button: TextureButton
@export var ui_game_life_points_meter: RkGuiProgressBar

@export var ui_pause_control: Control
@export var ui_pause_tab_container: TabContainer
@export var ui_pause_all_rooms_control: Control
@export var ui_pause_map_room_dot_control: Control

@export var ui_game_over_control: Control

static var _main_node: RkMain = null

signal room_enter(room_node: RkRoom) # emitted when the player enters a new room.
signal room_leave(room_node: RkRoom) # emitted when the player leaves the current room and will be emitted before the next room_enter.

var rng := RandomNumberGenerator.new()
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
	# start in pause if visible
	if ui_pause_control.visible:
		state = State.pause
		get_tree().paused  = true
		push_warning("Pause control is visible, game will start paused")
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
		ui_game_over_control.visible = true
		var tween := create_tween()
		tween.tween_property($CanvasModulate, "color", Color8(0, 0, 0), 1.0)
		tween.parallel().tween_property(ui_game_control, "modulate", Color8(0, 0, 0), 1.0)
		tween.parallel().tween_property(ui_pause_control, "modulate", Color8(0, 0, 0), 1.0)
		tween.parallel().tween_property(ui_game_over_control, "modulate", Color8(255, 255, 255), 1.0).from(Color8(255, 255, 255, 0))
		tween.parallel().tween_property($AudioStreamPlayer, "volume_db", -80.0, 1.0)
		tween.parallel().tween_callback($DeathAudioStreamPlayer.play).set_delay(0.1)
		tween.tween_property($Game, "modulate", Color8(0, 0, 0), 2.0).set_delay(5.0)
	)
	# setup level up animation
	player_node.level_system.level_up.connect(func(_level: int):
		if state == State.game:
			state = State.level_up
			ui_pause_control.visible = false
			level_up_animation_player.play("level_up!")
		level_up_audio_stream_player.play()
	)
	# setup picked up animation
	player_node.inventory_system.item_added.connect(func(item: RkItemRes, _index: int, swapped: bool):
		if swapped:
			return
		picked_up_label.text = "[offset x=-10][right]You picked up a [bounce][rainbow freq=0.5]%s.[/rainbow][/bounce][/right][/offset]" % [item.name]
		picked_up_animation_player.stop()
		picked_up_animation_player.play("picked_up!")
		picked_up_audio_stream_player.play()
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
func _process_game(delta: float):
	# gui update
	ui_game_state_label.text = player_node.fsm.current_state_node.name
	ui_game_stamina_meter.progress = move_toward(ui_game_stamina_meter.progress, player_node.stamina_system.stamina.ratio, delta)
	ui_game_life_points_meter.progress = move_toward(ui_game_life_points_meter.progress, player_node.life_points_system.life_points.ratio, delta)
	# pause game
	if Input.is_action_just_pressed("player_pause"):
		get_tree().paused = true
		state = State.pause
		ui_pause_control.visible = true
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
		ui_pause_control.visible = false
	# cycle pause tabs
	if Input.is_action_just_pressed("player_pause_next") or Input.is_action_just_pressed("player_pause_previous"):
		ui_pause_tab_container.current_tab = (ui_pause_tab_container.current_tab + 1) % ui_pause_tab_container.get_child_count()
	# position map dot
	ui_pause_map_room_dot_control.visible = true
	ui_pause_map_room_dot_control.position = (player_node.position * (RkMapRoom.MAP_ROOM_SIZE / Vector2(RkRoom.ROOM_SIZE)))

# @impure
func _process_level_up():
	# current_room_node.tile_map.set_layer_modulate(RkRoom.Layer.wall, level_up_label.get_theme_color("font_color"))
	if not level_up_animation_player.is_playing():
		get_tree().paused = false
		state = State.game
		# current_room_node.tile_map.set_layer_modulate(RkRoom.Layer.wall, Color8(255, 255, 255, 255))

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

# @impure
func _enter_room(room_node := current_room_node):
	current_room_node = room_node
	room_enter.emit(current_room_node)
	# mark room as discovered
	var map_room_control := _get_map_room_control(current_room_node.get_grid_pos())
	if map_room_control:
		map_room_control.discovered = true

# @impure
func _leave_room(room_node := current_room_node):
	previous_room_node = room_node
	room_leave.emit(previous_room_node)

# @impure
func _clear_rooms():
	for room_node in all_rooms_node.get_children():
		all_rooms_node.remove_child(room_node)
		room_node.queue_free()
	for map_room_control in ui_pause_all_rooms_control.get_children():
		ui_pause_all_rooms_control.remove_child(map_room_control)
		map_room_control.queue_free()

# @impure
func _instantiate_room(room_scene: PackedScene, room_grid_pos: Vector2i, distance: int) -> RkRoom:
	var room_node: RkRoom = room_scene.instantiate()
	room_node.name = _get_room_node_name(room_grid_pos)
	room_node.distance = distance
	room_node.position = room_grid_pos * RkRoom.ROOM_SIZE
	all_rooms_node.add_child(room_node)
	room_node.owner = all_rooms_node
	# create pause map room control
	var room_map_pos := Vector2(
		room_grid_pos.x * RkMapRoom.MAP_ROOM_SIZE.x,
		room_grid_pos.y * RkMapRoom.MAP_ROOM_SIZE.y
	)
	var map_room_control: RkMapRoom = MAP_ROOM_SCENE.instantiate()
	map_room_control.name = _get_map_room_control_name(room_grid_pos)
	map_room_control.room_node = room_node
	map_room_control.discovered = map_revealed
	map_room_control.set_position(room_map_pos)
	ui_pause_all_rooms_control.add_child(map_room_control)
	map_room_control.owner = ui_pause_all_rooms_control
	return room_node

# @pure
func _get_room_node(grid_pos: Vector2i) -> RkRoom:
	return all_rooms_node.find_child(_get_room_node_name(grid_pos))

# @pure
func _get_room_node_name(grid_pos: Vector2i) -> StringName:
	return "Room_%s_%s" % [grid_pos.x, grid_pos.y]

# @pure
func _get_map_room_control(grid_pos: Vector2i) -> RkMapRoom:
	return ui_pause_all_rooms_control.find_child(_get_map_room_control_name(grid_pos))

# @pure
func _get_map_room_control_name(grid_pos: Vector2i) -> StringName:
	return "MapRoom_%s_%s" % [grid_pos.x, grid_pos.y]

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
	ui_game_magic_slot_button.release_focus()
