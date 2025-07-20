@tool
extends Control
class_name RkGuiProgressBar

@export var margin := Vector2.ONE :
	get:
		return margin
	set(value):
		margin = value
		_update_progress()
@export var progress := 1.0 :
	get:
		return progress
	set(value):
		progress = value
		_update_progress()

@export var lag := true
@export var lag_delay := 0.35
@export var lag_speed := 30.0

@export var lag_color := RkColorTheme.GREEN_ALPHA :
	get:
		return lag_color
	set(value):
		lag_color = value
		_update_colors()
@export var value_color := RkColorTheme.GREEN :
	get:
		return value_color
	set(value):
		value_color = value
		_update_colors()
@export var margin_color := RkColorTheme.GOLD_ALPHA :
	get:
		return margin_color
	set(value):
		margin_color = value
		_update_colors()
@export var background_color := RkColorTheme.GRAY :
	get:
		return background_color
	set(value):
		background_color = value
		_update_colors()

var _lag_delay := lag_delay

# set_progress changes the progress to the given normalized value.
# note: use the progress property in script, this is an helper for connecting directly to signals.
# @impure
func set_progress(new_progress: float):
	progress = new_progress

# @impure
func _ready():
	_update_lag()
	_update_size()
	_update_colors()
	_update_progress()

# @impure
func _process(delta: float):
	if $ProgressBarLag.size.x <= $ProgressBarValue.size.x:
		_lag_delay = lag_delay
		$ProgressBarLag.size.x = $ProgressBarValue.size.x
	if _lag_delay > 0.0:
		_lag_delay -= delta
	if _lag_delay <= 0.0:
		_lag_delay = 0.0
		$ProgressBarLag.size.x = move_toward($ProgressBarLag.size.x, $ProgressBarValue.size.x, delta * lag_speed)

# @impure
func _update_lag():
	set_process(lag)
	$ProgressBarLag.visible = lag

# @impure
func _update_size():
	var rect := get_rect()
	$Margin.size = rect.size + margin * 2.0
	$Margin.position = -margin
	$Background.size = rect.size
	$ProgressBarLag.size = rect.size
	$ProgressBarValue.size = Vector2(lerpf(0.0, rect.size.x, progress), rect.size.y)

# @impure
func _update_colors():
	$Margin.color = margin_color
	$Background.color = background_color
	$ProgressBarLag.color = lag_color
	$ProgressBarValue.color = value_color

# @impure
func _update_progress():
	var rect := get_rect()
	$ProgressBarValue.size = Vector2(lerp(0.0, rect.size.x, progress), rect.size.y)

# @signal
# @impure
func _on_resized():
	_update_size()
