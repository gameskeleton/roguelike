extends Resource
class_name RkInventoryItemRes

@export var icon: Texture2D
@export var name := "Item"
@export_multiline var description := ""

@export_group("Statistics")
@export var gold_earn_multiplier := 0.0
@export var attack_force_bonus := 0.0
@export var attack_force_multiplier := 0.0
@export var attack_defence_bonus := 0.0
@export var attack_defence_multiplier := 0.0
@export var stamina_bonus := 0.0
@export var stamina_multiplier := 0.0
@export var stamina_regeneration_bonus := 0.0
@export var stamina_regeneration_multiplier := 0.0
@export var stamina_regeneration_delay_bonus := 0.0
@export var stamina_regeneration_delay_multiplier := 0.0
@export var life_points_bonus := 0.0
@export var life_points_multiplier := 0.0

# @impure
func apply_inventory_modifier(inventory_system: RkInventorySystem):
	if inventory_system.gold_system:
		inventory_system.gold_system.gold.value_earn_multiplier += gold_earn_multiplier
	if inventory_system.attack_system:
		inventory_system.attack_system.force.value_bonus += attack_force_bonus
		inventory_system.attack_system.force.value_multiplier += attack_force_multiplier
		inventory_system.attack_system.defence.value_bonus += attack_defence_bonus
		inventory_system.attack_system.defence.value_multiplier += attack_defence_multiplier
	if inventory_system.stamina_system:
		inventory_system.stamina_system.stamina.max_value_bonus += stamina_bonus
		inventory_system.stamina_system.stamina.max_value_multiplier += stamina_multiplier
		inventory_system.stamina_system.regeneration.value_bonus += stamina_regeneration_bonus
		inventory_system.stamina_system.regeneration.value_multiplier += stamina_regeneration_multiplier
		inventory_system.stamina_system.regeneration_delay.value_bonus += stamina_regeneration_delay_bonus
		inventory_system.stamina_system.regeneration_delay.value_multiplier += stamina_regeneration_delay_multiplier
	if inventory_system.life_points_system:
		inventory_system.life_points_system.life_points.max_value_bonus += life_points_bonus
		inventory_system.life_points_system.life_points.max_value_multiplier += life_points_multiplier

# @impure
static func reset_inventory_modifiers(inventory_system: RkInventorySystem):
	if inventory_system.gold_system:
		inventory_system.gold_system.gold.reset_modifiers()
	if inventory_system.attack_system:
		inventory_system.attack_system.force.reset_modifiers()
		inventory_system.attack_system.defence.reset_modifiers()
	if inventory_system.stamina_system:
		inventory_system.stamina_system.stamina.reset_modifiers()
		inventory_system.stamina_system.regeneration.reset_modifiers()
		inventory_system.stamina_system.regeneration_delay.reset_modifiers()
	if inventory_system.life_points_system:
		inventory_system.life_points_system.life_points.reset_modifiers()
