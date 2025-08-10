@tool
extends RkGuiProgressBar
class_name RkGuiProgressBarLifePoints

@export var life_points_system: RkLifePointsSystem

# @impure
func _ready():
	super._ready()
	if not Engine.is_editor_hint():
		life_points_system.life_points_changed.connect(_on_life_points_life_points_changed)

# @impure
func _exit_tree():
	if not Engine.is_editor_hint():
		life_points_system.life_points_changed.disconnect(_on_life_points_life_points_changed)

# @signal
# @impure
func _on_life_points_life_points_changed(_life_points: float, life_points_ratio: float, _life_points_previous: float):
	progress = life_points_ratio
