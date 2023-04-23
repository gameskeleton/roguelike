@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkInventorySystem

enum ItemType { item = 0, slot = 1 }

signal item_added(item: RkInventoryItemRes, index: int)
signal slot_added(slot: RkInventoryItemRes, index: int)
signal item_removed(item: RkInventoryItemRes, index: int)
signal slot_removed(slot: RkInventoryItemRes, index: int)

@export var default_items: Array[RkInventoryItemRes] = []
@export var default_slots: Array[RkInventoryItemRes] = []
@export var items_capacity := 20
@export var slots_capacity := 5

@export var gold_system: RkGoldSystem
@export var attack_system: RkAttackSystem
@export var stamina_system: RkStaminaSystem
@export var life_points_system: RkLifePointsSystem

var items: Array[RkInventoryItemRes] = []
var slots: Array[RkInventoryItemRes] = []

# @impure
func _ready():
	items.resize(items_capacity)
	slots.resize(slots_capacity)
	for item in default_items:
		add_item(item)
	for slot in default_slots:
		add_slot(slot)

# @impure
func add_item(item: RkInventoryItemRes, index := -1):
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
func add_slot(slot: RkInventoryItemRes, index := -1):
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
	var to_item: RkInventoryItemRes
	var from_item: RkInventoryItemRes
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
func _item_added(item: RkInventoryItemRes, index: int, _swapped := false):
	item_added.emit(item, index)

# @impure
func _item_removed(item: RkInventoryItemRes, index: int, _swapped := false):
	item_removed.emit(item, index)

# @impure
func _slot_added(slot: RkInventoryItemRes, index: int, _swapped := false):
	slot_added.emit(slot, index)
	_apply_slots_modifiers()

# @impure
func _slot_removed(slot: RkInventoryItemRes, index: int, _swapped := false):
	slot_removed.emit(slot, index)
	_apply_slots_modifiers()

# @impure
func _apply_slots_modifiers():
	# reset systems
	if gold_system:
		gold_system.gold.reset_bonus()
	if attack_system:
		attack_system.force.reset_bonus()
		attack_system.damage_multiplier_fire = 1.0
		attack_system.damage_multiplier_roll = 1.0
		attack_system.damage_multiplier_world = 1.0
		attack_system.damage_multiplier_physical = 1.0
	if stamina_system:
		stamina_system.stamina.reset_bonus()
	if life_points_system:
		life_points_system.life_points.reset_bonus()
		life_points_system.damage_multiplier_fire = 1.0
		life_points_system.damage_multiplier_roll = 1.0
		life_points_system.damage_multiplier_world = 1.0
		life_points_system.damage_multiplier_physical = 1.0
	# modify systems
	for slot in slots:
		if not slot:
			continue
		if gold_system:
			gold_system.gold.current_value_earn_multiplier *= slot.gold_earn_multiplier_bonus
		if attack_system:
			attack_system.force.max_value_bonus += slot.force_bonus
			attack_system.damage_multiplier_fire *= slot.attack_multiplier_fire
			attack_system.damage_multiplier_roll *= slot.attack_multiplier_roll
			attack_system.damage_multiplier_world *= slot.attack_multiplier_world
			attack_system.damage_multiplier_physical *= slot.attack_multiplier_physical
		if stamina_system:
			stamina_system.stamina.max_value_bonus += slot.stamina_bonus
		if life_points_system:
			life_points_system.life_points.max_value_bonus += slot.life_points_bonus
			life_points_system.damage_multiplier_fire *= slot.defence_multiplier_fire
			life_points_system.damage_multiplier_roll *= slot.defence_multiplier_roll
			life_points_system.damage_multiplier_world *= slot.defence_multiplier_world
			life_points_system.damage_multiplier_physical *= slot.defence_multiplier_physical

# find_system_node returns the inventory system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkInventorySystem:
	var system := node.get_node_or_null("Systems/Inventory")
	if system is RkInventorySystem:
		return system
	return null
