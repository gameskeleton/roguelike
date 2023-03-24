@tool
extends Node2D

enum Exit {
	none = 0,
	all = 15,
	#
	up = 1,
	down = 2,
	up_down = 3,
	left = 4,
	up_left = 5,
	down_left = 6,
	up_down_left = 7,
	right = 8,
	up_right = 9,
	down_right = 10,
	up_down_right = 11,
	left_right = 12,
	up_left_right = 13,
	down_left_right = 14,
}

@export var width := 1 :
	get:
		return width
	set(value):
		width = value
		_fill_all_exits()
		if Engine.is_editor_hint():
			queue_redraw()
@export var height := 1 :
	get:
		return height
	set(value):
		height = value
		_fill_all_exits()
		if Engine.is_editor_hint():
			queue_redraw()
@export var all_exits: Array[Exit] = [Exit.all] :
	get:
		return all_exits
	set(value):
		all_exits = value
		if Engine.is_editor_hint():
			queue_redraw()

const ROOM_COLOR := Color(0.0, 0.0, 0.0, 0.2)
const ROOM_WIDTH := 512.0
const ROOM_HEIGHT := 288.0
const ROOM_EXIT_VERTICAL_SIZE := Vector2(64.0, 64.0)
const ROOM_EXIT_HORIZONTAL_SIZE := Vector2(64.0, 64.0)

const VALID_EXIT_COLOR := Color(0.0, 1.0, 0.0, 0.2)
const INVALID_EXIT_COLOR := Color(1.0, 0.0, 0.0, 0.2)

func _draw():
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(0, 0, width * ROOM_WIDTH, height * ROOM_HEIGHT), ROOM_COLOR)
	for x in width:
		for y in height:
			var exits := all_exits[y + x * height]
			var off_x := x * ROOM_WIDTH
			var off_y := y * ROOM_HEIGHT
			if exits & Exit.up == Exit.up:
				draw_rect(Rect2(off_x + ROOM_WIDTH / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, off_y, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), VALID_EXIT_COLOR if y == 0 else INVALID_EXIT_COLOR)
			if exits & Exit.down == Exit.down:
				draw_rect(Rect2(off_x + ROOM_WIDTH / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, off_y + ROOM_HEIGHT - ROOM_EXIT_VERTICAL_SIZE.y, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), VALID_EXIT_COLOR if y == height - 1 else INVALID_EXIT_COLOR)
			if exits & Exit.left == Exit.left:
				draw_rect(Rect2(off_x, off_y + ROOM_HEIGHT / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), VALID_EXIT_COLOR if x == 0 else INVALID_EXIT_COLOR)
			if exits & Exit.right == Exit.right:
				draw_rect(Rect2(off_x + ROOM_WIDTH - ROOM_EXIT_HORIZONTAL_SIZE.x, off_y + ROOM_HEIGHT / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), VALID_EXIT_COLOR if x == width - 1 else INVALID_EXIT_COLOR)

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()

func _fill_all_exits():
	all_exits.clear()
	all_exits.resize(width * height)
	notify_property_list_changed()
