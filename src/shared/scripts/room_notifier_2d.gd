@icon("res://src/shared/icons/room_notifier_2d.svg")
extends Node2D
class_name RkRoomNotifier2D

signal room_enter() # emitted when we (the listen node) enter this room's rect.
signal room_leave() # emitted when we (the listen node) leave this room's rect.

@export var listen_room_node: Node2D = self
@export var listen_room_offset := Vector2.ZERO

var room_node: RkRoom # the room this notifier belongs to, by default the nearest room possible in this notifier parents.
var room_inside := false # whether this notifier is inside this room's collision rectangle.
var room_node_grid_pos: Vector2i # the room grid position.
var room_node_collision_rect: Rect2i  # the room collision rectangle.

# _ready finds the nearest room possible in this notifier parents.
# @impure
func _ready():
	var parent_node := get_parent()
	while parent_node:
		if parent_node is RkRoom:
			room_node = parent_node
			room_node_grid_pos = room_node.get_grid_pos()
			room_node_collision_rect = room_node.get_coll_rect()
			break
		parent_node = parent_node.get_parent()
	assert(room_node != null, "RkRoomNotifier2D must be a descendant of RkRoom")
	room_inside = _inside_room()
	if room_inside:
		room_enter.emit()

# _process checks if this notifier is inside this room's collision rectangle.
# @impure
func _process(_delta: float):
	var still_inside := _inside_room()
	if room_inside and not still_inside:
		room_inside = false
		room_leave.emit()
	elif not room_inside and still_inside:
		room_inside = true
		room_enter.emit()

# _inside_room returns true if this notifier is inside this room's collision rectangle.
# @pure
func _inside_room() -> bool:
	return room_node_collision_rect.has_point(listen_room_node.global_position + listen_room_offset)
