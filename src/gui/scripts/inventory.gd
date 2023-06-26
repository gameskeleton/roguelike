extends Control
class_name RkGuiInventory

@export var node: Node

@export_group("Nodes")
@export var inventory_drop: Control
@export var inventory_item_container: GridContainer
@export var inventory_slot_container: GridContainer
@export var inventory_drop_animation_player: AnimationPlayer

@export var stats_description: RichTextLabel
@export var description_item_name: Label
@export var description_item_description: RichTextLabel

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
	_update_stats_description()

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

# @pure
func _format_text(value: String):
	return "%s: " % [value]

# @pure
func _format_float(value: float):
	return "[color=#%s]%.0f[/color]" % [RkColorTheme.ORANGE.to_html(), value]

# @pure
func _format_item_bonus(value: float):
	return "[color=#%s]%s%.0f[/color]" % [RkColorTheme.DARK_RED.to_html() if value < 0.0 else RkColorTheme.DARK_GREEN.to_html(), "+" if value >= 0.0 else "", value]

# @pure
func _format_item_bonus_percentage(value: float):
	return "[color=#%s]%s%.0f%%[/color]" % [RkColorTheme.DARK_RED.to_html() if value < 0.0 else RkColorTheme.DARK_GREEN.to_html(), "+" if value >= 0.0 else "", ceilf(value * 100.0)]

# @impure
func _update_stats_description():
	stats_description.text = ""
	stats_description.text += "%s%s/%s\n" % [_format_text("Lvl"), _format_float(_level_system.level.value + 1), _format_float(_level_system.level.max_value + 1)]
	stats_description.text += "%s%s\n" % [_format_text("Gold"), _format_float(_gold_system.gold.value)]
	stats_description.text += "%s%s\n" % [_format_text("Force"), _format_float(_attack_system.force.value)]
	stats_description.text += "%s%s\n" % [_format_text("Defence"), _format_float(_attack_system.defence.value)]
	stats_description.text += "\n"
	stats_description.text += "%s%s/%s\n" % [_format_text("Stamina"), _format_float(_stamina_system.stamina.value), _format_float(_stamina_system.stamina.max_value)]
	stats_description.text += "%s%s\n" % [_format_text("Stamina regen"), _format_float(_stamina_system.regeneration.value)]
	stats_description.text += "%s%s/%s\n" % [_format_text("Life points"), _format_float(_life_points_system.life_points.value), _format_float(_life_points_system.life_points.max_value)]

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
