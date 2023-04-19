extends Resource
class_name RkInventoryItemRes

@export var icon: Texture2D
@export var name := "Item"
@export_multiline var description := ""

@export_group("Statistics")
@export var force_bonus := 0.0
@export var stamina_bonus := 0.0
@export var life_points_bonus := 0.0
@export var gold_earn_multiplier_bonus := 1.0

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
