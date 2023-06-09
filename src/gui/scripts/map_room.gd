extends Control
class_name RkMapRoom

const MAP_TILE_SIZE := 2
const MAP_ROOM_SIZE := Vector2((RkRoom.ROOM_SIZE.x / 16.0) * MAP_TILE_SIZE, (RkRoom.ROOM_SIZE.y / 16.0) * MAP_TILE_SIZE)

@export var empty_color := RkColorTheme.DARK_BLUE
@export var start_empty_color := RkColorTheme.DARK_GREEN
@export var border_color := RkColorTheme.GRAY
@export var start_border_color := RkColorTheme.GRAY
@export var one_way_color := RkColorTheme.BLUE
@export var start_one_way_color := RkColorTheme.GREEN

var room_node: RkRoom
var discovered := false

# @impure
func _draw():
	if not discovered:
		return
	var tiles := room_node.get_wall_tiles_with_border()
	var start_room := room_node.distance == 0
	# draw empty spaces and borders
	for y in RkRoom.ROOM_TILE_COUNT.y:
		for x in RkRoom.ROOM_TILE_COUNT.x:
			match tiles[y][x].z:
				RkRoom.Tile.none: draw_rect(Rect2(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE), start_empty_color if start_room else empty_color)
				RkRoom.Tile.border: draw_rect(Rect2(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE), start_border_color if start_room else border_color)
	# draw one way tiles
	for tile in room_node.get_one_way_tiles():
		draw_rect(Rect2(tile.x * MAP_TILE_SIZE, tile.y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE), start_one_way_color if start_room else one_way_color)

# @impure
func _process(_delta: float):
	queue_redraw()
