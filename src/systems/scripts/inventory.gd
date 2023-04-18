@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkInventorySystem

class RkInventorySlots:
	@export var armor: RkInventoryRes
	@export var weapon: RkInventoryRes
	@export var ring_01: RkInventoryRes
	@export var ring_02: RkInventoryRes
	
	# @impure
	func slot(item: RkInventoryRes) -> bool:
		match item.slot:
			RkInventoryRes.Slot.ring:
				if not ring_01:
					ring_01 = item
					return true
				if not ring_02:
					ring_02 = item
					return true
			RkInventoryRes.Slot.armor:
				if not armor:
					armor = item
					return true
			RkInventoryRes.Slot.weapon:
				if not weapon:
					weapon = item
					return true
		return false

	# @impure
	func unslot(item: RkInventoryRes) -> bool:
		match item.slot:
			RkInventoryRes.Slot.ring:
				if ring_01 == item:
					ring_01 = null
					return true
				if ring_02 == item:
					ring_02 = null
					return true
			RkInventoryRes.Slot.armor:
				if armor == item:
					armor = null
					return true
			RkInventoryRes.Slot.weapon:
				if weapon == item:
					weapon = null
					return true
		return false

signal added(item: RkInventoryRes)
signal removed(item: RkInventoryRes)
signal equipped(item: RkInventoryRes)
signal unequipped(item: RkInventoryRes)

@export var items: Array[RkInventoryRes] = []
@export var capacity := 10
@export var gold_system: RkGoldSystem
@export var attack_system: RkAttackSystem
@export var stamina_system: RkStaminaSystem
@export var life_points_system: RkLifePointsSystem

var slots := RkInventorySlots.new()

# @impure
func _ready():
	for item in items:
		added.emit(item)

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
func equip(item: RkInventoryRes) -> bool:
	if items.has(item):
		if slots.slot(item):
			_apply_item_to_systems(item)
			equipped.emit(item)
			return true
	return false

# @impure
func unequip(item: RkInventoryRes) -> bool:
	if items.has(item):
		if slots.unslot(item):
			_unapply_item_to_systems(item)
			unequipped.emit(item)
			return true
	return false

# @impure
func _apply_item_to_systems(item: RkInventoryRes):
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
func _unapply_item_to_systems(item: RkInventoryRes):
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
