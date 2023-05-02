@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkInventorySystem

enum ItemType { item = 0, slot = 1 }

signal item_added(item: RkItemRes, index: int)
signal slot_added(slot: RkItemRes, index: int)
signal item_removed(item: RkItemRes, index: int)
signal slot_removed(slot: RkItemRes, index: int)

@export var default_items: Array[RkItemRes] = []
@export var default_slots: Array[RkItemRes] = []
@export var items_capacity := 20
@export var slots_capacity := 5

@export var gold_system: RkGoldSystem
@export var attack_system: RkAttackSystem
@export var stamina_system: RkStaminaSystem
@export var life_points_system: RkLifePointsSystem

var items: Array[RkItemRes] = []
var slots: Array[RkItemRes] = []

# @impure
func _ready():
	items.resize(items_capacity)
	slots.resize(slots_capacity)
	for item in default_items:
		add_item(item)
	for slot in default_slots:
		add_slot(slot)

# @impure
func add_item(item: RkItemRes, index := -1):
	if index == -1:
		for i in items.size():
			if items[i] == null:
				items[i] = item
				_item_added(item, i)
				return true
	else:
		if items[index] == null:
				items[index] = item
				_item_added(item, index)
				return true
	return false

# @impure
func add_slot(slot: RkItemRes, index := -1):
	if index == -1:
		for i in slots.size():
			if slots[i] == null:
				slots[i] = slot
				_slot_added(slot, i)
				return true
	else:
		if slots[index] == null:
				slots[index] = slot
				_slot_added(slot, index)
				return true
	return false

# @impure
func remove_item(index: int):
	var removed_item := items[index]
	items[index] = null
	_item_removed(removed_item, index)

# @impure
func remove_slot(index: int):
	var removed_slot := slots[index]
	slots[index] = null
	_slot_removed(removed_slot, index)

# @impure
func drop_item_or_slot(from_type: RkInventorySystem.ItemType, from_index: int):
	match from_type:
		ItemType.item:
			var from_item := items[from_index]
			items[from_index] = null
			if from_item:
				_item_removed(from_item, from_index)
		ItemType.slot:
			var from_item := slots[from_index]
			slots[from_index] = null
			if from_item:
				_slot_removed(from_item, from_index)
			_apply_slots_modifiers()

# @impure
func move_item_or_slot(from_type: ItemType, from_index: int, to_type: ItemType, to_index: int):
	var to_item: RkItemRes
	var from_item: RkItemRes
	match to_type:
		ItemType.item: to_item = items[to_index]
		ItemType.slot: to_item = slots[to_index]
	match from_type:
		ItemType.item: from_item = items[from_index]
		ItemType.slot: from_item = slots[from_index]
	match to_type:
		ItemType.item: items[to_index] = from_item
		ItemType.slot: slots[to_index] = from_item
	match from_type:
		ItemType.item: items[from_index] = to_item
		ItemType.slot: slots[from_index] = to_item
	if to_type != from_type:
		if to_item:
			match to_type:
				ItemType.item:
					_item_removed(to_item, from_index, true)
					_slot_added(to_item, to_index, true)
				ItemType.slot:
					_slot_removed(to_item, from_index, true)
					_item_added(to_item, to_index, true)
		if from_item:
			match from_type:
				ItemType.item:
					_item_removed(from_item, from_index, true)
					_slot_added(from_item, to_index, true)
				ItemType.slot:
					_slot_removed(from_item, from_index, true)
					_item_added(from_item, to_index, true)

# @impure
func _item_added(item: RkItemRes, index: int, _swapped := false):
	item_added.emit(item, index)

# @impure
func _item_removed(item: RkItemRes, index: int, _swapped := false):
	item_removed.emit(item, index)

# @impure
func _slot_added(slot: RkItemRes, index: int, _swapped := false):
	slot_added.emit(slot, index)
	_apply_slots_modifiers()

# @impure
func _slot_removed(slot: RkItemRes, index: int, _swapped := false):
	slot_removed.emit(slot, index)
	_apply_slots_modifiers()

# @impure
func _apply_slots_modifiers():
	# reset bonuses
	RkItemRes.reset_inventory_modifiers(self)
	# apply bonuses in order
	for slot in slots:
		if not slot:
			continue
		slot.apply_inventory_modifier(self)

# find_system_node returns the inventory system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkInventorySystem:
	var system := node.get_node_or_null("Systems/Inventory")
	if system is RkInventorySystem:
		return system
	return null
