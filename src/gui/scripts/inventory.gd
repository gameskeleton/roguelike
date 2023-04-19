extends Control
class_name RkGuiInventory

@export var node: Node

@onready var slot_container: GridContainer= $HBoxContainer/SlotContainer
@onready var item_container: GridContainer= $HBoxContainer/ItemContainer

var _should_update := true
var _inventory_system: RkInventorySystem

# @impure
func _ready():
	_inventory_system = RkInventorySystem.find_system_node(node)
	_inventory_system.item_added.connect(func(_item: RkInventoryItemRes, _index: int): _update_cells())
	_inventory_system.slot_added.connect(func(_slot: RkInventoryItemRes, _index: int): _update_cells())
	_inventory_system.item_removed.connect(func(_item: RkInventoryItemRes, _index: int): _update_cells())
	_inventory_system.slot_removed.connect(func(_slot: RkInventoryItemRes, _index: int): _update_cells())
	_update_cells()

# @impure
func _notification(what: int):
	if what == NOTIFICATION_DRAG_END:
		_update_cells(true)

# @impure
func _update_cells(force := false):
	if not force and not _should_update:
		return
	for item_index in _inventory_system.items.size():
		var item_cell: RkGuiInventoryCell = item_container.get_child(item_index)
		item_cell.item = _inventory_system.items[item_index]
	for slot_index in _inventory_system.slots.size():
		var slot_cell: RkGuiInventoryCell = slot_container.get_child(slot_index)
		slot_cell.item = _inventory_system.slots[slot_index]

# @impure
# @callback
func move_item_or_slot(from_type: RkInventorySystem.ItemType, from_index: int, to_type: RkInventorySystem.ItemType, to_index: int):
	_should_update = false
	_inventory_system.move_item_or_slot(from_type, from_index , to_type, to_index)
	_should_update = true
