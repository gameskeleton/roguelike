extends Control
class_name RkMain

enum State { game, pause, level_up }

const PLAYER_SIZE := Vector2(14.0, 28.0)
const MAP_ROOM_SCENE: PackedScene = preload("res://src/gui/map_room.tscn")

@export var map_revealed := false
@export var start_room_scene: PackedScene

@onready var player_node: RkPlayer = $Game/Player
@onready var all_rooms_node: Node2D = $Game/AllRooms
@onready var player_camera_node: Camera2D = $Game/Player/Camera2D
@onready var pickup_spawner_node: RkPickupSpawner = $Game/PickupSpawner

@onready var ui_pause_control: Control = $CanvasLayer/Pause
@onready var ui_all_rooms_control: Control = $CanvasLayer/Pause/MapTab/Map/AllMapRooms
@onready var ui_map_room_dot_control: Control = $CanvasLayer/Pause/MapTab/Map/MapRoomDot

@onready var ui_gold_value_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/GoldValueLabel
@onready var ui_gold_bonus_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/GoldBonusLabel
@onready var ui_force_value_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/ForceValueLabel
@onready var ui_force_bonus_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/ForceBonusLabel
@onready var ui_level_value_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/LevelValueLabel
@onready var ui_level_bonus_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/LevelBonusLabel
@onready var ui_stamina_value_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/StaminaValueLabel
@onready var ui_stamina_bonus_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/StaminaBonusLabel
@onready var ui_experience_value_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/ExperienceValueLabel
@onready var ui_experience_bonus_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/ExperienceBonusLabel
@onready var ui_life_points_value_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/LifePointsValueLabel
@onready var ui_life_points_bonus_label: Label = $CanvasLayer/Pause/StatsTab/PlayerStats/LifePointsBonusLabel

@onready var ui_level_up_animation_player: AnimationPlayer = $Game/Player/LevelUpLabel/AnimationPlayer
@onready var ui_level_up_audio_stream_player: AudioStreamPlayer = $Game/Player/LevelUpLabel/AudioStreamPlayer

signal room_enter(room_node: RkRoom) # emitted when the player enters a new room.
signal room_leave(room_node: RkRoom) # emitted when the player leaves the current room and will be emitted before the next room_enter.

var rng := RandomNumberGenerator.new()
var state := State.game
var current_room_node: RkRoom # the room node the player is in.
var previous_room_node: RkRoom # the previous room node the player was in.

var _generator := RkDungeonGenerator.new()

# @impure
func _ready():
	# load start room scene or generate new dungeon
	if start_room_scene:
		_clear_rooms()
		var start_room_node := _instantiate_room(start_room_scene, Vector2i.ZERO, 0)
		var start_room_grid_pos := start_room_node.get_grid_pos()
		_enter_room(start_room_node)
		player_node.position = Vector2(start_room_grid_pos.x * RkRoom.ROOM_SIZE.x + start_room_node.player_spawn.x, start_room_grid_pos.y * RkRoom.ROOM_SIZE.y + start_room_node.player_spawn.y)
	else:
		_generate_dungeon()
	_limit_camera_to_room()
	player_node.level_system.level_up.connect(func(_level: int):
		if state == State.game:
			get_tree().paused  = true
			state = State.level_up
			ui_pause_control.visible = false
			ui_level_up_animation_player.play("level_up!")
		ui_level_up_audio_stream_player.play()
	)
	player_camera_node.reset_smoothing()

# @impure
func _process(delta: float):
	_process_debug()
	match state:
		State.game: _process_game(delta)
		State.pause: _process_pause(delta)
		State.level_up: _process_level_up()

# @impure
func _process_game(delta: float):
	# gui update
	$CanvasLayer/State.text = player_node.fsm.current_state_node.name
	$CanvasLayer/StaminaMeter.progress = move_toward($CanvasLayer/StaminaMeter.progress, player_node.stamina_system.get_ratio(), delta)
	$CanvasLayer/LifePointsMeter.progress = move_toward($CanvasLayer/LifePointsMeter.progress, player_node.life_points_system.get_ratio(), delta)
	# pause game
	if Input.is_action_just_pressed("player_pause"):
		get_tree().paused = true
		state = State.pause
		ui_pause_control.visible = true
	# room and camera
	var player_grid_pos := Vector2i(
		floor(player_node.position.x / RkRoom.ROOM_SIZE.x),
		floor(player_node.position.y / RkRoom.ROOM_SIZE.y)
	)
	if player_grid_pos != current_room_node.get_grid_pos():
		var room_node_at_player_grid_pos := _get_room_node(player_grid_pos)
		if current_room_node != room_node_at_player_grid_pos:
			_leave_room(current_room_node)
			_enter_room(room_node_at_player_grid_pos)
			_limit_camera_to_room()

# @impure
func _process_debug():
	if Input.is_action_just_pressed("ui_home"):
		_on_magic_slot_pressed()
	if Input.is_action_just_pressed("ui_page_up"):
		player_node.level_system.earn_experience(ceil(player_node.level_system.experience_required_to_level_up / 10.0))
	if Input.is_action_just_pressed("ui_page_down"):
		player_node.life_points_system.invincibility_delay = 0.0
		player_node.life_points_system.take_damage(ceil(player_node.life_points_system.max_life_points / 10.0))

# @impure
func _process_pause(_delta: float):
	# resume game
	if Input.is_action_just_pressed("player_pause"):
		get_tree().paused = false
		state = State.game
		ui_pause_control.visible = false
	# cycle pause tabs
	if Input.is_action_just_pressed("player_pause_next"):
		$CanvasLayer/Pause/MapTab.visible = false
		$CanvasLayer/Pause/StatsTab.visible = true
	if Input.is_action_just_pressed("player_pause_previous"):
		$CanvasLayer/Pause/MapTab.visible = true
		$CanvasLayer/Pause/StatsTab.visible = false
	# position map dot
	ui_map_room_dot_control.position = (player_node.position * (RkMapRoom.MAP_ROOM_SIZE / Vector2(RkRoom.ROOM_SIZE))) - (RkMapRoomDot.DOT_SIZE * 0.5)
	# update stats values
	_format_stat(ui_gold_value_label, player_node.gold_system.gold.current_value)
	_format_stat(ui_force_value_label, player_node.attack_system.force.max_value)
	_format_stat(ui_level_value_label, player_node.level_system.level + 1, player_node.level_system.max_level + 1)
	_format_stat(ui_stamina_value_label, player_node.stamina_system.stamina.current_value, player_node.stamina_system.stamina.max_value)
	_format_stat(ui_experience_value_label, player_node.level_system.experience, player_node.level_system.experience_required_to_level_up)
	_format_stat(ui_life_points_value_label, player_node.life_points_system.life_points.current_value, player_node.life_points_system.life_points.max_value)
	_format_stat_bonus(ui_gold_bonus_label, player_node.gold_system.gold.max_value_bonus)
	_format_stat_bonus(ui_force_bonus_label, player_node.attack_system.force.max_value_bonus)
	_format_stat_bonus(ui_stamina_bonus_label, player_node.stamina_system.stamina.max_value_bonus)
	_format_stat_bonus(ui_life_points_bonus_label, player_node.life_points_system.life_points.max_value_bonus)

# @impure
func _process_level_up():
	current_room_node.tile_map.set_layer_modulate(RkRoom.Layer.wall, $Game/Player/LevelUpLabel.get_theme_color("font_color"))
	if not ui_level_up_animation_player.is_playing():
		get_tree().paused = false
		state = State.game
		current_room_node.tile_map.set_layer_modulate(RkRoom.Layer.wall, Color8(255, 255, 255, 255))

# @pure
static func get_main_node(from_node: Node) -> RkMain:
	return from_node.get_tree().root.get_node("/root/Main")

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
	for map_room_control in ui_all_rooms_control.get_children():
		ui_all_rooms_control.remove_child(map_room_control)
		map_room_control.queue_free()

# @impure
func _instantiate_room(room_scene: PackedScene, room_grid_pos: Vector2i, distance: int) -> RkRoom:
	var room_node: Node2D = room_scene.instantiate()
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
	ui_all_rooms_control.add_child(map_room_control)
	map_room_control.owner = ui_all_rooms_control
	return room_node

# @pure
func _get_room_node(grid_pos: Vector2i) -> RkRoom:
	return all_rooms_node.find_child(_get_room_node_name(grid_pos))

# @pure
func _get_room_node_name(grid_pos: Vector2i) -> StringName:
	return "Room_%s_%s" % [grid_pos.x, grid_pos.y]

# @pure
func _get_map_room_control(grid_pos: Vector2i) -> RkMapRoom:
	return ui_all_rooms_control.find_child(_get_map_room_control_name(grid_pos))

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
				if room_scenes.has(cell_exits):
					# create dungeon room node
					var room_node := _instantiate_room(RkUtils.pick_random(room_scenes[cell_exits], rng), Vector2i(x, y), distance)
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

# @impure
func _format_stat(value_label: Label, value: float, max_value := -1.0):
	if max_value > 0.0:
		value_label.text = "%d / %d" % [value, max_value]
	else:
		value_label.text = "%d" % [value]

# @impure
func _format_stat_bonus(bonus_label: Label, bonus: float):
	if bonus >= 0.0:
		bonus_label.text = "(+%d)" % [bonus]
		bonus_label.add_theme_color_override("font_color", RkColorTheme.DARK_GREEN)
	else:
		bonus_label.text = "(-%d)" % [absf(bonus)]
		bonus_label.add_theme_color_override("font_color", RkColorTheme.DARK_RED)

# @signal
# @impure
func _on_magic_slot_pressed():
	_generate_dungeon()
	_limit_camera_to_room()
	$CanvasLayer/MagicSlot.release_focus()
