@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkInventorySystem

signal added(item: RkInventoryRes)
signal removed(item: RkInventoryRes)
signal equipped(item: RkInventoryRes, slot: int)
signal unequipped(item: RkInventoryRes, slot: int)

@export var default_items: Array[RkInventoryRes] = []
@export var default_equip_items: Array[RkInventoryRes] = []

@export_group("Capacity")
@export var capacity := 20
@export var equip_capacity := 5

@export_group("System nodes")
@export var gold_system: RkGoldSystem
@export var attack_system: RkAttackSystem
@export var stamina_system: RkStaminaSystem
@export var life_points_system: RkLifePointsSystem

var items: Array[RkInventoryRes] = [] # dense array
var equipped_items: Array[RkInventoryRes] = [] # sparse array

# @impure
func _ready():
	equipped_items.resize(equip_capacity)
	# start by adding default_equip_items
	for item in default_equip_items:
		if not add(item):
			break
		if not equip_slot(item, default_equip_items.find(item)):
			break
	# add default items
	for item in default_items:
		if not add(item):
			break

# @impure
func add(item: RkInventoryRes) -> bool:
	if items.size() >= capacity:
		return false
	items.append(item)
	added.emit(item)
	return true

# @impure
func remove(item: RkInventoryRes) -> bool:
	if items.has(item):
		items.erase(item)
		removed.emit(item)
		return true
	return false

# @impure
func equip_slot(item: RkInventoryRes, slot: int) -> bool:
	assert(slot >= 0, "slot must be positive")
	assert(slot < equip_capacity - 1, "slot must be less than equip_capacity")
	if items.has(item):
		if equipped_items[slot]:
			return false
		_unapply_equipped_items_to_systems()
		equipped_items[slot] = item
		_apply_equipped_items_to_systems()
		equipped.emit(item, slot)
		return true
	return false

# @impure
func unequip_slot(item: RkInventoryRes, slot: int) -> bool:
	assert(slot >= 0, "slot must be positive")
	assert(slot < equip_capacity - 1, "slot must be less than equip_capacity")
	if items.has(item):
		if equipped_items[slot]:
			_unapply_equipped_items_to_systems()
			equipped_items[slot] = null
			_apply_equipped_items_to_systems()
			unequipped.emit(item, slot)
			return true
	return false

# @impure
func _apply_equipped_items_to_systems():
	for item in equipped_items:
		if not item:
			continue
		if gold_system:
			gold_system.earn_multiplier *= item.gold_earn_multiplier_bonus
		if attack_system:
			attack_system.force_bonus += item.force_bonus
			attack_system.damage_multiplier_fire *= item.attack_multiplier_fire
			attack_system.damage_multiplier_roll *= item.attack_multiplier_roll
			attack_system.damage_multiplier_world *= item.attack_multiplier_world
			attack_system.damage_multiplier_physical *= item.attack_multiplier_physical
		if stamina_system:
			stamina_system.max_stamina_bonus += item.stamina_bonus
		if life_points_system:
			life_points_system.max_life_points_bonus += item.life_points_bonus
			life_points_system.damage_multiplier_fire *= item.defence_multiplier_fire
			life_points_system.damage_multiplier_roll *= item.defence_multiplier_roll
			life_points_system.damage_multiplier_world *= item.defence_multiplier_world
			life_points_system.damage_multiplier_physical *= item.defence_multiplier_physical

# @impure
func _unapply_equipped_items_to_systems():
	for item in equipped_items:
		if not item:
			continue
		if gold_system:
			gold_system.earn_multiplier /= item.gold_earn_multiplier_bonus
		if attack_system:
			attack_system.force_bonus -= item.force_bonus
			attack_system.damage_multiplier_fire /= item.attack_multiplier_fire
			attack_system.damage_multiplier_roll /= item.attack_multiplier_roll
			attack_system.damage_multiplier_world /= item.attack_multiplier_world
			attack_system.damage_multiplier_physical /= item.attack_multiplier_physical
		if stamina_system:
			stamina_system.max_stamina_bonus -= item.stamina_bonus
		if life_points_system:
			life_points_system.max_life_points_bonus -= item.life_points_bonus
			life_points_system.damage_multiplier_fire /= item.defence_multiplier_fire
			life_points_system.damage_multiplier_roll /= item.defence_multiplier_roll
			life_points_system.damage_multiplier_world /= item.defence_multiplier_world
			life_points_system.damage_multiplier_physical /= item.defence_multiplier_physical
