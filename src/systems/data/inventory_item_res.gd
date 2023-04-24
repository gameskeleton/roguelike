extends Resource
class_name RkInventoryItemRes

@export var icon: Texture2D
@export var name := "Item"
@export_multiline var description := ""

@export_group("Statistics")
@export var gold_earn_multiplier := 1.0
@export var attack_force_bonus := 0.0
@export var attack_force_multiplier := 1.0
@export var attack_defence_bonus := 0.0
@export var attack_defence_multiplier := 1.0
@export var stamina_bonus := 0.0
@export var stamina_multiplier := 1.0
@export var stamina_regeneration_bonus := 0.0
@export var stamina_regeneration_multiplier := 1.0
@export var stamina_regeneration_delay_bonus := 0.0
@export var stamina_regeneration_delay_multiplier := 1.0
@export var life_points_bonus := 0.0
@export var life_points_multiplier := 1.0

@export_group("Attack multipliers", "attack_multiplier")
@export var attack_multiplier_roll := 1.0
@export var attack_multiplier_fire := 1.0
@export var attack_multiplier_world := 1.0
@export var attack_multiplier_physical := 1.0

@export_group("Defence multipliers", "defence_multiplier")
@export var defence_multiplier_roll := 1.0
@export var defence_multiplier_fire := 1.0
@export var defence_multiplier_world := 1.0
@export var defence_multiplier_physical := 1.0

# @impure
func apply_inventory_modifier(inventory_system: RkInventorySystem):
	if inventory_system.gold_system:
		inventory_system.gold_system.gold.current_value_earn_multiplier *= gold_earn_multiplier
	if inventory_system.attack_system:
		inventory_system.attack_system.force.max_value_bonus += attack_force_bonus
		inventory_system.attack_system.force.max_value_multiplier *= attack_force_multiplier
		inventory_system.attack_system.damage_multiplier_fire *= attack_multiplier_fire
		inventory_system.attack_system.damage_multiplier_roll *= attack_multiplier_roll
		inventory_system.attack_system.damage_multiplier_world *= attack_multiplier_world
		inventory_system.attack_system.damage_multiplier_physical *= attack_multiplier_physical
	if inventory_system.stamina_system:
		inventory_system.stamina_system.stamina.max_value_bonus += stamina_bonus
		inventory_system.stamina_system.stamina.max_value_multiplier *= stamina_multiplier
		inventory_system.stamina_system.regeneration.max_value_bonus += stamina_regeneration_bonus
		inventory_system.stamina_system.regeneration.max_value_multiplier *= stamina_regeneration_multiplier
		inventory_system.stamina_system.regeneration_delay.max_value_bonus += stamina_regeneration_delay_bonus
		inventory_system.stamina_system.regeneration_delay.max_value_multiplier *= stamina_regeneration_delay_multiplier
	if inventory_system.life_points_system:
		inventory_system.life_points_system.life_points.max_value_bonus += life_points_bonus
		inventory_system.life_points_system.life_points.max_value_multiplier *= life_points_multiplier
		inventory_system.life_points_system.damage_multiplier_fire *= defence_multiplier_fire
		inventory_system.life_points_system.damage_multiplier_roll *= defence_multiplier_roll
		inventory_system.life_points_system.damage_multiplier_world *= defence_multiplier_world
		inventory_system.life_points_system.damage_multiplier_physical *= defence_multiplier_physical

# @impure
static func reset_inventory_modifiers(inventory_system: RkInventorySystem):
	if inventory_system.gold_system:
		inventory_system.gold_system.gold.reset_bonus()
	if inventory_system.attack_system:
		inventory_system.attack_system.force.reset_bonus()
		inventory_system.attack_system.damage_multiplier_fire = 1.0
		inventory_system.attack_system.damage_multiplier_roll = 1.0
		inventory_system.attack_system.damage_multiplier_world = 1.0
		inventory_system.attack_system.damage_multiplier_physical = 1.0
	if inventory_system.stamina_system:
		inventory_system.stamina_system.stamina.reset_bonus()
		inventory_system.stamina_system.regeneration.reset_bonus()
		inventory_system.stamina_system.regeneration_delay.reset_bonus()
	if inventory_system.life_points_system:
		inventory_system.life_points_system.life_points.reset_bonus()
		inventory_system.life_points_system.damage_multiplier_fire = 1.0
		inventory_system.life_points_system.damage_multiplier_roll = 1.0
		inventory_system.life_points_system.damage_multiplier_world = 1.0
		inventory_system.life_points_system.damage_multiplier_physical = 1.0
