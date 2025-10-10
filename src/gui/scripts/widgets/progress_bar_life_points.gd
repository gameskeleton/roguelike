@tool
extends RkGuiProgressBar
class_name RkGuiProgressBarLifePoints

const FADE_SPEED := 2.0
const VISIBLE_FOR := 2.5

@export var life_points_system: RkLifePointsSystem

var _fade_in = 0.0
var _visible = true
var _visible_for = 0.0

# @impure
func fade_in():
	_visible = true
	_visible_for = VISIBLE_FOR

# @impure
func fade_out():
	_fade_in = 0.0
	_visible = false
	_visible_for = VISIBLE_FOR
	modulate.a = 0.0


# @impure
func _ready():
	super._ready()
	fade_out()
	if not Engine.is_editor_hint():
		life_points_system.life_points_changed.connect(_on_life_points_life_points_changed)

# @impure
func _process(delta: float):
	super._process(delta)
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
	modulate.a = ease(_fade_in, -2.0)

# @impure
func _exit_tree():
	if not Engine.is_editor_hint():
		life_points_system.life_points_changed.disconnect(_on_life_points_life_points_changed)

# @signal
# @impure
func _on_life_points_life_points_changed(_life_points: float, life_points_ratio: float, _life_points_previous: float):
	progress = life_points_ratio
	fade_in()
