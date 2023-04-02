@icon("res://src/shared/icons/room_notifier_2d.svg")
extends Node2D
class_name RkRoomNotifier2D

signal room_enter() # emitted when we enter this room. WILL NOT BE emitted on start: we expect the notifier to be in the room.
signal room_leave() # emitted when we leave this room.
signal player_enter() # emitted when the player enters this room. WILL BE emitted on start if the player is in the same room as the notifier.
signal player_leave() # emitted when the player leaves this room.

@export_group("Room", "listen_room")
@export var listen_room_on := true # whether to emit room_enter/room_leave and update room_inside.
@export var listen_room_node: Node2D = self
@export var listen_room_offset := Vector2.ZERO

@export_group("Player", "listen_player")
@export var listen_player_on := true # whether to emit player_enter/player_leave and update player_inside.

var room_node: RkRoom # the room this notifier belongs to, by default the nearest room possible in this notifier parents.
var room_node_grid_pos: Vector2i # the room grid position.
var room_node_collision_rect: Rect2i  # the room collision rectangle.

var room_inside := false : # whether this notifier is inside this room's collision rectangle. WILL NOT BE UPDATED if listen_room_on is set to false.
	get:
		if not listen_room_on:
			push_error("room_inside cannot be accessed if listen_room_on is set to false")
		return room_inside
var player_inside := false : # whether the player inside the same room. WILL NOT BE UPDATED if listen_player_on is set to false.
	get:
		if not listen_player_on:
			push_error("player_inside cannot be accessed if listen_room_on is set to false")
		return player_inside

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
	assert(room_node != null, "RoomNotifier2D must be a descendant of RkRoom")
	room_inside = _inside_room()
	set_process(listen_room_on)
	if listen_player_on:
		RkMain.get_main_node(self).room_enter.connect(_on_room_enter)
		RkMain.get_main_node(self).room_leave.connect(_on_room_leave)

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

# _on_room_enter is called when the player enters a room, we check if it entered ours.
# @signal
# @impure
func _on_room_enter(enter_room_node: RkRoom):
	if room_node == enter_room_node:
		player_inside = true
		player_enter.emit()

# _on_room_leave is called when the player leaves a room, we check if it left ours.
# @signal
# @impure
func _on_room_leave(enter_room_node: RkRoom):
	if room_node == enter_room_node:
		player_inside = false
		player_leave.emit()
