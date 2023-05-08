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
	none = 0,
	wall = 1,
	border = 2
}

enum Layer {
	bg = 0,
	decor_behind = 1,
	wall = 2,
	one_way = 3,
	decor_front = 4,
}

const ROOM_SIZE := Vector2i(512, 288)
const ROOM_TILE_COUNT := Vector2i(32, 18)

const ROOM_EXIT_COLOR := Color(0.0, 1.0, 0.0, 0.2)
const ROOM_EXIT_VERTICAL_SIZE := Vector2(64.0, 64.0)
const ROOM_EXIT_HORIZONTAL_SIZE := Vector2(64.0, 64.0)

const PLAYER_SPAWN_COLOR := Color(1.0, 1.0, 1.0, 0.6)

const WALL_CORNER_ATLAS_COORDS := [Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(0, 3), Vector2i(2, 3)]

@export var distance := 0 # distance from start room

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

# _draw will draw this room exits in the editor.
# @impure
func _draw():
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(player_spawn.x - RkPlayer.SIZE.x / 2.0, player_spawn.y - RkPlayer.SIZE.x / 2.0, RkPlayer.SIZE.x, RkPlayer.SIZE.y), PLAYER_SPAWN_COLOR)
	if exit_up:
		draw_rect(Rect2(ROOM_SIZE.x / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, 0.0, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_down:
		draw_rect(Rect2(ROOM_SIZE.x / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, ROOM_SIZE.y - ROOM_EXIT_VERTICAL_SIZE.y, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_left:
		draw_rect(Rect2(0.0, ROOM_SIZE.y / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_right:
		draw_rect(Rect2(ROOM_SIZE.x - ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_SIZE.y / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)

# _ready will queue a redraw in the editor.
# @impure
func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

# has_corner_tile returns true if there is a corner tile at the given position.
# @pure
func has_corner_tile(pos: Vector2) -> bool:
	var atlas_coords := tile_map.get_cell_atlas_coords(Layer.wall, tile_map.local_to_map(pos))
	return WALL_CORNER_ATLAS_COORDS.has(atlas_coords)

# get_corner_tile_pos returns the top-center position of the corner tile.
# note: calling this when has_corner_tile of the given position is false will yield incorrect results.
# @pure
func get_corner_tile_pos(pos: Vector2) -> Vector2:
	return tile_map.map_to_local(tile_map.local_to_map(pos))

# get_grid_pos returns the position in the grid of this room.
# @pure
func get_grid_pos() -> Vector2i:
	return Vector2i(floor(position.x / ROOM_SIZE.x), floor(position.y / ROOM_SIZE.y))

# get_coll_rect returns the collision rectangle of this room.
# @pure
func get_coll_rect() -> Rect2i:
	return Rect2i(get_grid_pos() * RkRoom.ROOM_SIZE, RkRoom.ROOM_SIZE)

# get_wall_tiles returns the position of all wall tiles in this room's tilemap.
# @pure
func get_wall_tiles() -> Array[Vector2i]:
	return tile_map.get_used_cells(Layer.wall)

# get_one_way_tiles returns the position of all one way tiles in this room's tilemap.
# @pure
func get_one_way_tiles() -> Array[Vector2i]:
	return tile_map.get_used_cells(Layer.one_way)

# get_wall_tiles_with_border returns a 2D grid of all wall tiles and add border tiles around the walls, useful for drawing map.
# @pure
func get_wall_tiles_with_border() -> Array[Array]:
	var tiles_grid: Array[Array] = []
	var used_tiles := tile_map.get_used_cells(Layer.wall)
	# fill tile grid
	tiles_grid.resize(ROOM_TILE_COUNT.y)
	for y in ROOM_TILE_COUNT.y:
		tiles_grid[y].resize(ROOM_TILE_COUNT.x)
		for x in ROOM_TILE_COUNT.x:
			tiles_grid[y][x] = Vector3i(x, y, Tile.wall if used_tiles.has(Vector2i(x, y)) else Tile.none)
	# generate border for each filled tile
	for y in ROOM_TILE_COUNT.y:
		for x in ROOM_TILE_COUNT.x:
			var tile: Vector3i = tiles_grid[y][x]
			if tile.z == 0:
				if tile.x > 0 and tile.y > 0 and tiles_grid[tile.y - 1][tile.x - 1].z == Tile.wall: tiles_grid[tile.y - 1][tile.x - 1].z = Tile.border
				if tile.x > 0 and tile.y < ROOM_TILE_COUNT.y - 1 and tiles_grid[tile.y + 1][tile.x - 1].z == Tile.wall: tiles_grid[tile.y + 1][tile.x - 1].z = Tile.border
				if tile.x < ROOM_TILE_COUNT.x - 1 and tile.y > 0 and tiles_grid[tile.y - 1][tile.x + 1].z == Tile.wall: tiles_grid[tile.y - 1][tile.x + 1].z = Tile.border
				if tile.x < ROOM_TILE_COUNT.x - 1 and tile.y < ROOM_TILE_COUNT.y - 1 and tiles_grid[tile.y + 1][tile.x + 1].z == Tile.wall: tiles_grid[tile.y + 1][tile.x + 1].z = Tile.border
	return tiles_grid

# generate_room_exits_name returns a list of human readable exits.
# @pure
static func generate_room_exits_name(exits: Exit) -> String:
	var exit_parts: Array[String] = []
	# sort alphabetically to get the same order in the filesystem
	if exits & Exit.down == Exit.down: exit_parts.push_back("down")
	if exits & Exit.left == Exit.left: exit_parts.push_back("left")
	if exits & Exit.right == Exit.right: exit_parts.push_back("right")
	if exits & Exit.up == Exit.up: exit_parts.push_back("up")
	return "_".join(exit_parts)
