extends Control
class_name RkGuiInventory

@export var node: Node

@onready var stats_gold_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/GoldValueLabel
@onready var stats_gold_bonus_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/GoldBonusLabel
@onready var stats_level_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/LevelValueLabel
@onready var stats_force_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/ForceValueLabel
@onready var stats_force_bonus_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/ForceBonusLabel
@onready var stats_defence_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/DefenceValueLabel
@onready var stats_defence_bonus_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/DefenceBonusLabel
@onready var stats_stamina_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/StaminaValueLabel
@onready var stats_stamina_bonus_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/StaminaBonusLabel
@onready var stats_stamina_regen_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/StaminaRegenValueLabel
@onready var stats_stamina_regen_bonus_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/StaminaRegenBonusLabel
@onready var stats_experience_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/ExperienceValueLabel
@onready var stats_life_points_value_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/LifePointsValueLabel
@onready var stats_life_points_bonus_label: Label = $HBoxContainer/Statistics/Stats/ScrollContainer/VBoxContainer/MarginContainer/GridContainer/LifePointsBonusLabel

@onready var inventory_drop: Control = $HBoxContainer/Inventory/Equip/VBoxContainer/CenterContainer/InventoryDrop
@onready var inventory_item_container: GridContainer = $HBoxContainer/Inventory/Equip/VBoxContainer/ItemContainer
@onready var inventory_slot_container: GridContainer = $HBoxContainer/Inventory/Equip/VBoxContainer/SlotContainer
@onready var inventory_drop_animation_player: AnimationPlayer = $HBoxContainer/Inventory/Equip/VBoxContainer/CenterContainer/InventoryDrop/AnimationPlayer

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
	_update_stats_label(stats_defence_value_label, _attack_system.defence.max_value)
	_update_stats_label(stats_level_value_label, _level_system.level + 1, _level_system.max_level + 1)
	_update_stats_label(stats_stamina_value_label, _stamina_system.stamina.current_value, _stamina_system.stamina.max_value)
	_update_stats_label(stats_experience_value_label, _level_system.experience, _level_system.experience_required_to_level_up)
	_update_stats_label(stats_life_points_value_label, _life_points_system.life_points.current_value, _life_points_system.life_points.max_value)
	_update_stats_label(stats_stamina_regen_value_label, _stamina_system.regeneration.current_value, -1.0, " / s")
	_update_stats_label_bonus(stats_force_bonus_label, _attack_system.force)
	_update_stats_label_bonus(stats_defence_bonus_label, _attack_system.defence)
	_update_stats_label_bonus(stats_stamina_bonus_label, _stamina_system.stamina)
	_update_stats_label_bonus(stats_life_points_bonus_label, _life_points_system.life_points)
	_update_stats_label_bonus(stats_stamina_regen_bonus_label, _stamina_system.regeneration)
	_update_stats_label_earn_multiplier(stats_gold_bonus_label, _gold_system.gold)

# @impure
func _notification(what: int):
	match what:
		NOTIFICATION_DRAG_END:
			inventory_drop_animation_player.play("disappear")
			_update_cells(true)
		NOTIFICATION_DRAG_BEGIN:
			inventory_drop_animation_player.play("appear")

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
func _update_stats_label(value_label: Label, value: float, max_value := -1.0, suffix := ""):
	if max_value > 0.0:
		value_label.text = "%d / %d" % [value, max_value]
	elif not suffix.is_empty():
		value_label.text = "%d%s" % [value, suffix]
	else:
		value_label.text = "%d" % [value]

# @impure
func _update_stats_label_bonus(bonus_label: Label, value: RkAdvFloat):
	var bonus := value.max_value - value.max_value_base
	bonus_label.modulate.a = 0.0 if is_equal_approx(bonus, 0.0) else 1.0
	if bonus >= 0.0:
		bonus_label.text = "(+%d)" % [bonus]
		bonus_label.add_theme_color_override("font_color", RkColorTheme.DARK_GREEN)
	else:
		bonus_label.text = "(-%d)" % [absf(bonus)]
		bonus_label.add_theme_color_override("font_color", RkColorTheme.DARK_RED)

# @impure
func _update_stats_label_earn_multiplier(earn_label: Label, value: RkAdvFloat):
	var earn_multiplier := value.current_value_earn_multiplier
	earn_label.modulate.a = 0.0 if is_equal_approx(earn_multiplier, 1.0) else 1.0
	if earn_multiplier > 1.0:
		earn_label.text = "(+%d%%)" % [ceilf((earn_multiplier - 1.0) * 100.0)]
		earn_label.add_theme_color_override("font_color", RkColorTheme.DARK_GREEN)
	elif earn_multiplier < 1.0:
		earn_label.text = "(-%d%%)" % [absf(floorf((earn_multiplier - 1.0) * 100.0))]
		earn_label.add_theme_color_override("font_color", RkColorTheme.DARK_RED)

# @impure
# @callback
func drop_item_or_slot(from_type: RkInventorySystem.ItemType, from_index: int):
	_should_update = false
	_inventory_system.drop_item_or_slot(from_type, from_index)
	_should_update = true
	
# @impure
# @callback
func move_item_or_slot(from_type: RkInventorySystem.ItemType, from_index: int, to_type: RkInventorySystem.ItemType, to_index: int):
	_should_update = false
	_inventory_system.move_item_or_slot(from_type, from_index, to_type, to_index)
	_should_update = true
