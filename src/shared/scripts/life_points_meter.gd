extends Control

@export var life_points: RkLifePoints

@onready var progress_bar: RkGuiProgressBar = $ProgressBar

# @impure
func _ready():
	if not life_points:
		var parent_node := get_parent()
		if parent_node:
			life_points = RkLifePoints.find_life_points_in_node(parent_node)
	assert(life_points, "LifePointsMeter must be a sibling of RkLifePoints")
	life_points.damage_taken.connect(_on_life_points_damage_taken)
	progress_bar._update_progress()

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _life_points: float, _source: Object, _instigator: Object):
	progress_bar.progress = life_points.get_ratio()
