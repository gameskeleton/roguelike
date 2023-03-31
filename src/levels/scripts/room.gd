@tool
extends Node2D
class_name RkRoom

enum Exit {
	up = 0x1,
	down = 0x2,
	left = 0x4,
	right = 0x8
}

enum Tile {
	empty = 0,
	filled = 1,
	border = 2
}

enum Layer {
	bg = 0,
	decor_behind = 1,
	wall = 2,
	one_way = 3,
	decor_front = 4,
}

const ROOM_SIZE := Vector2(512.0, 288.0)
const ROOM_TILE_COUNT := Vector2i(32, 18)
const ROOMS_DIRECTORY := "res://src/levels/rooms"

const ROOM_EXIT_COLOR := Color(0.0, 1.0, 0.0, 0.2)
const ROOM_EXIT_VERTICAL_SIZE := Vector2(64.0, 64.0)
const ROOM_EXIT_HORIZONTAL_SIZE := Vector2(64.0, 64.0)

const PLAYER_SPAWN_COLOR := Color(1.0, 1.0, 1.0, 0.6)

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
@export var player_spawn := ROOM_SIZE / 2.0:
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
	draw_rect(Rect2(player_spawn.x - RkMain.PLAYER_SIZE.x / 2.0, player_spawn.y - RkMain.PLAYER_SIZE.x / 2.0, RkMain.PLAYER_SIZE.x, RkMain.PLAYER_SIZE.y), PLAYER_SPAWN_COLOR)
	if exit_up:
		draw_rect(Rect2(ROOM_SIZE.x / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, 0.0, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_down:
		draw_rect(Rect2(ROOM_SIZE.x / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, ROOM_SIZE.y - ROOM_EXIT_VERTICAL_SIZE.y, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_left:
		draw_rect(Rect2(0.0, ROOM_SIZE.y / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_right:
		draw_rect(Rect2(ROOM_SIZE.x - ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_SIZE.y / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

func get_wall_tiles() -> Array[Vector2i]:
	return tile_map.get_used_cells(Layer.wall)

func get_one_way_tiles() -> Array[Vector2i]:
	return tile_map.get_used_cells(Layer.one_way)

func get_wall_tiles_with_border() -> Array[Array]:
	var tiles_grid: Array[Array] = []
	var used_tiles := tile_map.get_used_cells(Layer.wall)
	# fill tile grid
	tiles_grid.resize(ROOM_TILE_COUNT.y)
	for y in ROOM_TILE_COUNT.y:
		tiles_grid[y].resize(ROOM_TILE_COUNT.x)
		for x in ROOM_TILE_COUNT.x:
			tiles_grid[y][x] = Vector3i(x, y, Tile.filled if used_tiles.has(Vector2i(x, y)) else Tile.empty)
	# generate border for each used tile
	for y in ROOM_TILE_COUNT.y:
		for x in ROOM_TILE_COUNT.x:
			var tile: Vector3i = tiles_grid[y][x]
			if tile.z == 0:
				if tile.x > 0 and tile.y > 0 and tiles_grid[tile.y - 1][tile.x - 1].z == Tile.filled: tiles_grid[tile.y - 1][tile.x - 1].z = Tile.border
				if tile.x > 0 and tile.y < 17 and tiles_grid[tile.y + 1][tile.x - 1].z == Tile.filled: tiles_grid[tile.y + 1][tile.x - 1].z = Tile.border
				if tile.x < 31 and tile.y > 0 and tiles_grid[tile.y - 1][tile.x + 1].z == Tile.filled: tiles_grid[tile.y - 1][tile.x + 1].z = Tile.border
				if tile.x < 31 and tile.y < 17 and tiles_grid[tile.y + 1][tile.x + 1].z == Tile.filled: tiles_grid[tile.y + 1][tile.x + 1].z = Tile.border
	return tiles_grid
