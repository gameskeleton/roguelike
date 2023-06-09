extends Control

const FADE_SPEED := 2.0
const VISIBLE_FOR := 2.5

@export var life_points_system: RkLifePointsSystem

@export_group("Nodes")
@export var progress_bar: RkGuiProgressBar

var _fade_in := 0.0
var _visible := true
var _visible_for := 2.0

# @impure
func _ready():
	if not life_points_system:
		var parent_node := get_parent()
		if parent_node:
			life_points_system = RkLifePointsSystem.find_system_node(parent_node)
	assert(life_points_system, "LifePointsMeter must be a sibling of RkLifePointsSystem")
	await get_tree().process_frame # small hack to wait for life_points_system to be ready
	progress_bar.progress = life_points_system.life_points.ratio
	life_points_system.damage_taken.connect(_on_life_points_damage_taken)

# @impure
func _process(delta: float):
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

# @impure
func _enter_room(_room: RkRoom):
	fade_in()

# @impure
func _leave_room(_room: RkRoom):
	fade_out()

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

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node):
	fade_in()
	progress_bar.progress = life_points_system.life_points.ratio
