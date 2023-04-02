@icon("res://src/utilities/icons/on_room_enter_notifier_2d.svg")
extends Node2D
class_name RkOnRoomEnterNotifier2D

# room_enter is triggered when the player enters the room in which this notifier is.
signal room_enter()
# room_leave is triggered when the player leaves this room in which this notifier is.
signal room_leave()

var active := false
var room_node: RkRoom

# _ready finds the nearest room possible in this node parents.
# @impure
func _ready():
	var parent_node := get_parent()
	while parent_node:
		if parent_node is RkRoom:
			room_node = parent_node
			break
		parent_node = parent_node.get_parent()
	assert(room_node != null, "RkOnRoomEnterNotifier2D must be a descendant of RkRoom")
	RkMain.get_main_node(self).room_enter.connect(_on_room_enter)
	RkMain.get_main_node(self).room_leave.connect(_on_room_leave)

func _on_room_enter(enter_room_node: RkRoom):
	if room_node == enter_room_node:
		active = true
		room_enter.emit()

func _on_room_leave(enter_room_node: RkRoom):
	if room_node == enter_room_node:
		active = false
		room_leave.emit()
