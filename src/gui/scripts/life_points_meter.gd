extends Control

const FADE_SPEED := 2.0
const VISIBLE_FOR := 2.5

@export var life_points: RkLifePointsSystem

@onready var progress_bar: RkGuiProgressBar = $ProgressBar

var _fade_in := 0.0
var _visible := true
var _visible_for := 2.0

# @impure
func fade_in():
	_visible = true
	_visible_for = VISIBLE_FOR

# @impure
func fade_out():
	_fade_in = 0.0
	_visible = false
	_visible_for = VISIBLE_FOR
	progress_bar.modulate.a = 0.0

# @impure
func _ready():
	set_process(false)
	if not life_points:
		var parent_node := get_parent()
		if parent_node:
			life_points = RkLifePointsSystem.find_system(parent_node)
	assert(life_points, "LifePointsMeter must be a sibling of RkLifePointsSystem")
	life_points.damage_taken.connect(_on_life_points_damage_taken)
	progress_bar.progress = life_points.get_ratio()

# @impure
func _process(delta):
	if _visible:
		if _fade_in < 1.0:
			_fade_in += delta * FADE_SPEED
		if _fade_in >= 1.0:
			_visible_for -= delta
			if _visible_for <= 0.0:
				_visible = false
				_visible_for = 0.0
	if not _visible and _fade_in > 0.0:
		_fade_in -= delta * FADE_SPEED
	progress_bar.modulate.a = ease(_fade_in, -2.0)

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node):
	fade_in()
	progress_bar.progress = life_points.get_ratio()

# @signal
# @impure
func _on_room_notifier_2d_player_enter():
	fade_in()
	set_process(true)

# @signal
# @impure
func _on_room_notifier_2d_player_leave():
	fade_out()
	set_process(false)
