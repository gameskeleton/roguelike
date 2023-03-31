extends Control
class_name RkMapRoom

const TILE_SIZE := 2
const MAP_ROOM_SIZE := Vector2((RkMain.ROOM_SIZE.x / 16.0) * TILE_SIZE, (RkMain.ROOM_SIZE.y / 16.0) * TILE_SIZE)

@export var bg_color: Color
@export var wall_color: Color
@export var one_way_color: Color

var room_node: RkRoom
var discovered := false

func _draw():
	if not discovered:
		return
	draw_rect(Rect2(0, 0, MAP_ROOM_SIZE.x, MAP_ROOM_SIZE.y), bg_color)
	for tile in room_node.get_wall_tiles():
		draw_rect(Rect2(tile.x * TILE_SIZE, tile.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), wall_color)
	for tile in room_node.get_one_way_tiles():
		draw_rect(Rect2(tile.x * TILE_SIZE, tile.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), one_way_color)

func _process(_delta: float):
	queue_redraw()
