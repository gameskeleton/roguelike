@tool
extends Node2D

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

const ROOM_COLOR := Color(0.0, 0.0, 0.0, 0.2)
const ROOM_EXIT_COLOR := Color(0.0, 1.0, 0.0, 0.2)
const ROOM_EXIT_VERTICAL_SIZE := Vector2(64.0, 64.0)
const ROOM_EXIT_HORIZONTAL_SIZE := Vector2(64.0, 64.0)

func _draw():
	if not Engine.is_editor_hint():
		return
	if exit_up:
		draw_rect(Rect2(RkMain.ROOM_WIDTH / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, 0.0, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_down:
		draw_rect(Rect2(RkMain.ROOM_WIDTH / 2.0 - ROOM_EXIT_VERTICAL_SIZE.x / 2.0, RkMain.ROOM_HEIGHT - ROOM_EXIT_VERTICAL_SIZE.y, ROOM_EXIT_VERTICAL_SIZE.x, ROOM_EXIT_VERTICAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_left:
		draw_rect(Rect2(0.0, RkMain.ROOM_HEIGHT / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)
	if exit_right:
		draw_rect(Rect2(RkMain.ROOM_WIDTH - ROOM_EXIT_HORIZONTAL_SIZE.x, RkMain.ROOM_HEIGHT / 2.0 - ROOM_EXIT_HORIZONTAL_SIZE.y / 2.0, ROOM_EXIT_HORIZONTAL_SIZE.x, ROOM_EXIT_HORIZONTAL_SIZE.y), ROOM_EXIT_COLOR)

func _ready():
	if Engine.is_editor_hint():
		queue_redraw()
