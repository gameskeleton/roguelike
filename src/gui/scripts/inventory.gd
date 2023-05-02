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

@onready var description_item_name: Label = $HBoxContainer/Statistics/Description/VBoxContainer/ItemName
@onready var description_item_description: RichTextLabel = $HBoxContainer/Statistics/Description/VBoxContainer/ItemDescription

var _should_update := true
var _selected_cell: RkGuiInventoryCell

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
	_inventory_system.item_added.connect(func(_item: RkItemRes, _index: int): _update_cells())
	_inventory_system.slot_added.connect(func(_slot: RkItemRes, _index: int): _update_cells())
	_inventory_system.item_removed.connect(func(_item: RkItemRes, _index: int): _update_cells())
	_inventory_system.slot_removed.connect(func(_slot: RkItemRes, _index: int): _update_cells())
	_update_cells()

# @impure
func _process(_delta: float):
	# update base stats
	_update_stats_int(stats_gold_value_label, _gold_system.gold)
	_update_stats_int(stats_force_value_label, _attack_system.force)
	_update_stats_int(stats_defence_value_label, _attack_system.defence)
	_update_stats_int_range(stats_experience_value_label, _level_system.experience, _level_system.experience_required_to_level_up)
	_update_stats_rpg_int_range(stats_level_value_label, _level_system.level, 1)
	_update_stats_rpg_float_range(stats_stamina_value_label, _stamina_system.stamina)
	_update_stats_rpg_float_range(stats_life_points_value_label, _life_points_system.life_points)
	_update_stats_simple_float_unit(stats_stamina_regen_value_label, _stamina_system.regeneration, " /s")
	# update bonus stats
	_update_stats_earn_rpg_float(stats_gold_bonus_label, _gold_system.gold)
	_update_stats_bonus_rpg_float(stats_stamina_bonus_label, _stamina_system.stamina)
	_update_stats_bonus_rpg_float(stats_life_points_bonus_label, _life_points_system.life_points)
	_update_stats_bonus_simple_float(stats_force_bonus_label, _attack_system.force)
	_update_stats_bonus_simple_float(stats_defence_bonus_label, _attack_system.defence)
	_update_stats_bonus_simple_float(stats_stamina_regen_bonus_label, _stamina_system.regeneration)

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
	_update_item_name_and_description(_selected_cell.item if _selected_cell else null)

# @impure
func _update_stats_int(value_label: Label, stats: Object):
	if stats is RkRpgFloat:
		value_label.text = "%d" % [(stats as RkRpgFloat).value]
	elif stats is RkRpgSimpleFloat:
		value_label.text = "%d" % [(stats as RkRpgSimpleFloat).value]

# @impure
func _update_stats_int_range(value_label: Label, value: int, max_value: int, increment := 0):
	value_label.text = "%d / %d" % [value + increment, max_value + increment]

# @impure
func _update_stats_rpg_int_range(value_label: Label, stats: RkRpgInteger, increment := 0):
	value_label.text = "%d / %d" % [stats.value + increment, stats.max_value + increment]

# @impure
func _update_stats_simple_float_unit(value_label: Label, stats: RkRpgSimpleFloat, unit: String):
	value_label.text = "%.1f%s" % [stats.value, unit]

# @impure
func _update_stats_rpg_float_range(value_label: Label, stats: RkRpgFloat):
	value_label.text = "%.1f / %.1f" % [stats.value, stats.max_value]

# @impure
func _update_stats_earn_rpg_float(earn_label: Label, stats: RkRpgFloat):
	var zero := is_equal_approx(stats.value_earn_multiplier, 1.0)
	var positive := stats.value_earn_multiplier >= 1.0 and not stats.lower_is_better
	var font_color := RkColorTheme.DARK_GREEN if positive else RkColorTheme.DARK_RED
	var multiplier_percentage := (stats.value_earn_multiplier - 1.0) * 100.0
	earn_label.text = ("+%.0f%%" % [ceilf(multiplier_percentage)]) if positive else ("-%.0f%%" % [absf(floorf(multiplier_percentage))])
	earn_label.modulate.a = 0.0 if zero else 1.0
	earn_label.add_theme_color_override("font_color", font_color)

# @impure
func _update_stats_bonus_float(bonus_label: Label, bonus: float, lower_is_better: bool):
	var zero := absf(bonus) < 0.5
	var positive := bonus >= 0.0 and not lower_is_better
	var font_color := RkColorTheme.DARK_GREEN if positive else RkColorTheme.DARK_RED
	bonus_label.text = ("+%d" % [bonus]) if positive else ("-%d" % [absf(bonus)])
	bonus_label.modulate.a = 0.0 if zero else 1.0
	bonus_label.add_theme_color_override("font_color", font_color)

# @impure
func _update_stats_bonus_rpg_float(bonus_label: Label, stats: RkRpgFloat):
	_update_stats_bonus_float(bonus_label, stats.max_value - stats.max_value_base, stats.lower_is_better)

# @impure
func _update_stats_bonus_simple_float(bonus_label: Label, stats: RkRpgSimpleFloat):
	_update_stats_bonus_float(bonus_label, stats.value - stats.value_base, stats.lower_is_better)

# @impure
func _format_item_bonus(value: float):
	return "[color=#%s]%s%.0f[/color]" % [RkColorTheme.DARK_RED.to_html() if value < 0.0 else RkColorTheme.DARK_GREEN.to_html(), "+" if value >= 0.0 else "", value]

# @impure
func _format_item_bonus_percentage(value: float):
	return "[color=#%s]%s%.0f%%[/color]" % [RkColorTheme.DARK_RED.to_html() if value < 0.0 else RkColorTheme.DARK_GREEN.to_html(), "+" if value >= 0.0 else "", ceilf(value * 100.0)]

# @impure
func _update_item_name_and_description(item: RkItemRes):
	if item:
		description_item_name.text = item.name
		description_item_description.text = ""
		if item.life_points_bonus != 0.0:
			description_item_description.text += "Life points: %s\n" % [_format_item_bonus(item.life_points_bonus)]
		if item.life_points_multiplier != 0.0:
			description_item_description.text += "Life points: %s\n" % [_format_item_bonus_percentage(item.life_points_multiplier)]
		if item.gold_earn_multiplier != 0.0:
			description_item_description.text += "Gold pickup: %s\n" % [_format_item_bonus_percentage(item.gold_earn_multiplier)]
		if item.attack_force_bonus != 0.0:
			description_item_description.text += "Force: %s\n" % [_format_item_bonus(item.attack_force_bonus)]
		if item.attack_force_multiplier != 0.0:
			description_item_description.text += "Force: %s\n" % [_format_item_bonus_percentage(item.attack_force_multiplier)]
		if item.attack_defence_bonus != 0.0:
			description_item_description.text += "Defence: %s\n" % [_format_item_bonus(item.attack_defence_bonus)]
		if item.attack_defence_multiplier != 0.0:
			description_item_description.text += "Defence: %s\n" % [_format_item_bonus_percentage(item.attack_defence_multiplier)]
		if item.stamina_bonus != 0.0:
			description_item_description.text += "Stamina: %s\n" % [_format_item_bonus(item.stamina_bonus)]
		if item.stamina_multiplier != 0.0:
			description_item_description.text += "Stamina: %s\n" % [_format_item_bonus_percentage(item.stamina_multiplier)]
		if item.stamina_regeneration_bonus != 0.0:
			description_item_description.text += "Stamina regeneration: %s\n" % [_format_item_bonus(item.stamina_regeneration_bonus)]
		if item.stamina_regeneration_multiplier != 0.0:
			description_item_description.text += "Stamina regeneration: %s\n" % [_format_item_bonus_percentage(item.stamina_regeneration_multiplier)]
		if item.description != "":
			description_item_description.text += "%s[i][color=#%s]%s[/color][/i]" % ["" if description_item_description.text == "" else "\n", RkColorTheme.GRAY.to_html(), item.description]
	else:
		description_item_name.text = "No item selected"
		description_item_description.text = ""

# @impure
# @callback
func select_cell(cell: RkGuiInventoryCell):
	if _selected_cell:
		_selected_cell.selected = false
	cell.selected = true
	_selected_cell = cell
	_update_item_name_and_description(cell.item)

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
