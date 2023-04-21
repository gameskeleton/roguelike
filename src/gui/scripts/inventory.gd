extends Control
class_name RkGuiInventory

@export var node: Node

@onready var stats_gold_value_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/GoldValueLabel
@onready var stats_gold_bonus_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/GoldBonusLabel
@onready var stats_force_value_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/ForceValueLabel
@onready var stats_force_bonus_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/ForceBonusLabel
@onready var stats_level_value_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/LevelValueLabel
@onready var stats_stamina_value_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/StaminaValueLabel
@onready var stats_stamina_bonus_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/StaminaBonusLabel
@onready var stats_experience_value_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/ExperienceValueLabel
@onready var stats_life_points_value_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/LifePointsValueLabel
@onready var stats_life_points_bonus_label: Label = $MarginContainer/HBoxContainer/Statistics/MarginContainer/GridContainer/LifePointsBonusLabel

@onready var inventory_item_container: GridContainer= $MarginContainer/HBoxContainer/Inventory/MarginContainer/HBoxContainer/ItemContainer
@onready var inventory_slot_container: GridContainer= $MarginContainer/HBoxContainer/Inventory/MarginContainer/HBoxContainer/SlotContainer

var _should_update := true
var _gold_system: RkGoldSystem
var _level_system: RkLevelSystem
var _attack_system: RkAttackSystem
var _stamina_system: RkStaminaSystem
var _inventory_system: RkInventorySystem
var _life_points_system: RkLifePointsSystem

# @impure
func _ready():
	# cache systems
	_gold_system = RkGoldSystem.find_system_node(node)
	_level_system = RkLevelSystem.find_system_node(node)
	_attack_system = RkAttackSystem.find_system_node(node)
	_stamina_system = RkStaminaSystem.find_system_node(node)
	_inventory_system = RkInventorySystem.find_system_node(node)
	_life_points_system = RkLifePointsSystem.find_system_node(node)
	# connect signals
	_inventory_system.item_added.connect(func(_item: RkInventoryItemRes, _index: int): _update_cells())
	_inventory_system.slot_added.connect(func(_slot: RkInventoryItemRes, _index: int): _update_cells())
	_inventory_system.item_removed.connect(func(_item: RkInventoryItemRes, _index: int): _update_cells())
	_inventory_system.slot_removed.connect(func(_slot: RkInventoryItemRes, _index: int): _update_cells())
	_update_cells()

# @impure
func _process(_delta: float):
	_update_stats_label(stats_gold_value_label, _gold_system.gold.current_value)
	_update_stats_label(stats_force_value_label, _attack_system.force.max_value)
	_update_stats_label(stats_level_value_label, _level_system.level + 1, _level_system.max_level + 1)
	_update_stats_label(stats_stamina_value_label, _stamina_system.stamina.current_value, _stamina_system.stamina.max_value)
	_update_stats_label(stats_experience_value_label, _level_system.experience, _level_system.experience_required_to_level_up)
	_update_stats_label(stats_life_points_value_label, _life_points_system.life_points.current_value, _life_points_system.life_points.max_value)
	_update_stats_label_bonus(stats_gold_bonus_label, _gold_system.gold.max_value_bonus)
	_update_stats_label_bonus(stats_force_bonus_label, _attack_system.force.max_value_bonus)
	_update_stats_label_bonus(stats_stamina_bonus_label, _stamina_system.stamina.max_value_bonus)
	_update_stats_label_bonus(stats_life_points_bonus_label, _life_points_system.life_points.max_value_bonus)

# @impure
func _notification(what: int):
	if what == NOTIFICATION_DRAG_END:
		_update_cells(true)

# @impure
func _update_cells(force := false):
	if not force and not _should_update:
		return
	for item_index in _inventory_system.items.size():
		var item_cell: RkGuiInventoryCell = inventory_item_container.get_child(item_index)
		item_cell.item = _inventory_system.items[item_index]
	for slot_index in _inventory_system.slots.size():
		var slot_cell: RkGuiInventoryCell = inventory_slot_container.get_child(slot_index)
		slot_cell.item = _inventory_system.slots[slot_index]

# @impure
func _update_stats_label(value_label: Label, value: float, max_value := -1.0):
	if max_value > 0.0:
		value_label.text = "%d / %d" % [value, max_value]
	else:
		value_label.text = "%d" % [value]

# @impure
func _update_stats_label_bonus(bonus_label: Label, bonus: float):
	if bonus >= 0.0:
		bonus_label.text = "(+%d)" % [bonus]
		bonus_label.add_theme_color_override("font_color", RkColorTheme.DARK_GREEN)
	else:
		bonus_label.text = "(-%d)" % [absf(bonus)]
		bonus_label.add_theme_color_override("font_color", RkColorTheme.DARK_RED)

# @impure
# @callback
func move_item_or_slot(from_type: RkInventorySystem.ItemType, from_index: int, to_type: RkInventorySystem.ItemType, to_index: int):
	_should_update = false
	_inventory_system.move_item_or_slot(from_type, from_index , to_type, to_index)
	_should_update = true
