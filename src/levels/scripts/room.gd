@tool
extends Node2D
class_name RkRoom

enum Exit {
	up = 0x1,
	down = 0x2,
	left = 0x4,
	right = 0x8
}

enum Layer {
	bg = 0,
	decor_behind = 1,
	wall = 2,
	one_way = 3,
	decor_front = 4,
}

const PLAYER_COLOR := Color(1.0, 1.0, 1.0, 0.6)
const ROOM_EXIT_COLOR := Color(0.0, 1.0, 0.0, 0.2)

@export_category("Exits")
@export var exit_up := false :
	get:
		return exit_up
	set(value):
		exit_up = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var exit_down := false :
	get:
		return exit_down
	set(value):
		exit_down = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var exit_left := false :
	get:
		return exit_left
	set(value):
		exit_left = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var exit_right := false :
	get:
		return exit_right
	set(value):
		exit_right = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var player_spawn := RkMain.ROOM_SIZE / 2.0:
	get:
		return player_spawn
	set(value):
		player_spawn = value
		if Engine.is_editor_hint():
			queue_redraw()

@onready var tile_map: TileMap = $Tilemap

func _draw():
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(player_spawn.x - RkMain.PLAYER_SIZE.x / 2.0, player_spawn.y - RkMain.PLAYER_SIZE.x / 2.0, RkMain.PLAYER_SIZE.x, RkMain.PLAYER_SIZE.y), PLAYER_COLOR)
	if exit_up:
		draw_rect(Rect2(RkMain.ROOM_SIZE.x / 2.0 - RkMain.ROOM_EXIT_VERTICAL_SIZE.x / 2.0, 0.0, RkMain.ROOM_EXIT_VERTICAL_SIZE.x, RkMain.ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_down:
		draw_rect(Rect2(RkMain.ROOM_SIZE.x / 2.0 - RkMain.ROOM_EXIT_VERTICAL_SIZE.x / 2.0, RkMain.ROOM_SIZE.y - RkMain.ROOM_EXIT_VERTICAL_SIZE.y, RkMain.ROOM_EXIT_VERTICAL_SIZE.x, RkMain.ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_left:
		draw_rect(Rect2(0.0, RkMain.ROOM_SIZE.y / 2.0 - RkMain.ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, RkMain.ROOM_EXIT_HORIZONTAL_SIZE.x, RkMain.ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_right:
		draw_rect(Rect2(RkMain.ROOM_SIZE.x - RkMain.ROOM_EXIT_HORIZONTAL_SIZE.x, RkMain.ROOM_SIZE.y / 2.0 - RkMain.ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, RkMain.ROOM_EXIT_HORIZONTAL_SIZE.x, RkMain.ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

func get_wall_tiles() -> Array[Vector2i]:
	return tile_map.get_used_cells(Layer.wall)

func get_one_way_tiles() -> Array[Vector2i]:
	return tile_map.get_used_cells(Layer.one_way)
