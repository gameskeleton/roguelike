@icon("res://src/shared/icons/system.svg")
extends Node
class_name RkLevelSystem

signal level_up(level: int) # emitted when levelling up, can be emitted multiple times in a frame.

var level := RkRpgInteger.create(0, 0, 9)
var experience := 0

var experience_required_to_level_up: int :
	get:
		return roundi(pow((level.value + 1), 1.8) + (level.value + 1) * 4.0)

# @impure
func _init(start_level := 0, start_experience := 0):
	level.value = start_level
	earn_experience(start_experience)

# get_xp_ratio returns the ratio [0; 1] between experience and the experience required to level up.
# @pure
func get_xp_ratio() -> float:
	return float(experience) / float(experience_required_to_level_up)

# can_level_up returns true if the player has not reached max level.
# @pure
func can_level_up():
	return level.value < level.max_value

# earn_experience adds the given amount of experience and level up accordingly.
# @impure
func earn_experience(amount_exp: int):
	experience += amount_exp
	var experience_required := experience_required_to_level_up
	while experience >= experience_required:
		if not can_level_up():
			experience = experience_required
			return
		level.add(1)
		experience -= experience_required
		level_up.emit(level.value)

# find_system_node returns the level system in the given node, or null if not found.
# @pure
static func find_system_node(node: Node) -> RkLevelSystem:
	var system := node.get_node_or_null("Systems/Level")
	if system is RkLevelSystem:
		return system as RkLevelSystem
	return null
