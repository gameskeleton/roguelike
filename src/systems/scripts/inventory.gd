@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkInventorySystem

enum ItemType { slot = 0, item = 1 }

signal item_added(item: RkInventoryRes, index: int)
signal slot_added(slot: RkInventoryRes, index: int)

@export var default_items: Array[RkInventoryRes] = []
@export var default_slots: Array[RkInventoryRes] = []
@export var items_capacity := 20
@export var slots_capacity := 5

var items: Array[RkInventoryRes] = []
var slots: Array[RkInventoryRes] = []

# @impure
func _ready():
	items.resize(items_capacity)
	slots.resize(slots_capacity)
	for item in default_items:
		add_item(item)
	for slot in default_slots:
		add_slot(slot)

# @impure
func add_item(item: RkInventoryRes, index := -1):
	if index == -1:
		for i in items.size():
			if items[i] == null:
				items[i] = item
				item_added.emit(item, i)
				return true
	else:
		if items[index] == null:
				items[index] = item
				item_added.emit(item, index)
				return true
	return false

# @impure
func add_slot(slot: RkInventoryRes, index := -1):
	if index == -1:
		for i in slots.size():
			if slots[i] == null:
				slots[i] = slot
				slot_added.emit(slot, i)
				return true
	else:
		if slots[index] == null:
				slots[index] = slot
				slot_added.emit(slot, index)
				return true
	return false

# @impure
func move_item_or_slot(from_type: ItemType, from_index: int, to_type: ItemType, to_index: int):
	var to_item: RkInventoryRes
	var from_item: RkInventoryRes
	match to_type:
		ItemType.slot: to_item = slots[to_index]
		ItemType.item: to_item = items[to_index]
	match from_type:
		ItemType.slot: from_item = slots[from_index]
		ItemType.item: from_item = items[from_index]
	match to_type:
		ItemType.slot: slots[to_index] = from_item
		ItemType.item: items[to_index] = from_item
	match from_type:
		ItemType.slot: slots[from_index] = to_item
		ItemType.item: items[from_index] = to_item

# find_system_node returns the inventory system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkInventorySystem:
	var system := node.get_node_or_null("Systems/Inventory")
	if system is RkInventorySystem:
		return system
	return null
