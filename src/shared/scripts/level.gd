@icon("res://src/shared/icons/level.svg")
extends Node
class_name RkLevel

signal level_up(level: int) # emitted when levelling up, can be emitted multiple times in a frame.

@export var level := 0
@export var max_level := 10
@export var experience := 0

var experience_required_to_level_up: int :
	get:
		return int(round(pow(1.0, 1.8) + 1.0 * 4.0))

# @impure
func _init(start_level := 0, start_experience := 0):
	level = start_level
	earn_experience(start_experience)

# get_ratio returns the ratio [0; 1] between level and max level.
# @pure
func get_ratio() -> float:
	return float(level) / float(max_level)

# get_xp_ratio returns the ratio [0; 1] between experience and the experience required to level up.
# @pure
func get_xp_ratio() -> float:
	return float(experience) / float(experience_required_to_level_up)

# can_level_up returns true if the player has not reached max level.
# @pure
func can_level_up():
	return level < max_level

# earn_experience adds the given amount of experience and level up accordingly.
# @impure
func earn_experience(amount_exp: int):
	experience += amount_exp
	var experience_required := experience_required_to_level_up
	while experience >= experience_required:
		if not can_level_up():
			experience = experience_required
			return
		level += 1
		experience -= experience_required
		level_up.emit(level)
