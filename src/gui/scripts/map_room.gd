extends Control
class_name RkMapRoom

const MAP_TILE_SIZE := 3
const MAP_ROOM_SIZE := Vector2((RkMain.ROOM_SIZE.x / 16.0) * MAP_TILE_SIZE, (RkMain.ROOM_SIZE.y / 16.0) * MAP_TILE_SIZE)

@export var empty_color: Color
@export var border_color: Color
@export var one_way_color: Color

var room_node: RkRoom
var discovered := false

func _draw():
	if not discovered:
		return
	var tiles := room_node.get_wall_tiles_with_border()
	# draw empty spaces and borders
	for y in RkRoom.TILE_COUNT.y:
		for x in RkRoom.TILE_COUNT.x:
			match tiles[y][x].z:
				RkRoom.Tile.empty: draw_rect(Rect2(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE), empty_color)
				RkRoom.Tile.border: draw_rect(Rect2(x * MAP_TILE_SIZE, y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE), border_color)
	# draw one way tiles
	for tile in room_node.get_one_way_tiles():
		draw_rect(Rect2(tile.x * MAP_TILE_SIZE, tile.y * MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE), one_way_color)

func _process(_delta: float):
	queue_redraw()