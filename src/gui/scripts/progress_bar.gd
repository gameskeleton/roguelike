@tool
extends Control
class_name RkGuiProgressBar

@export var color := Color("00ff00ff") :
	get:
		return color
	set(value):
		color = value
		_update_colors()
@export var lag_color := Color("00ff0064") :
	get:
		return lag_color
	set(value):
		lag_color = value
		_update_colors()
@export var margin_color := Color("ffd30064") :
	get:
		return margin_color
	set(value):
		margin_color = value
		_update_colors()
@export var background_color := Color("333333") :
	get:
		return background_color
	set(value):
		background_color = value
		_update_colors()

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

var _lag_delay := lag_delay

# @impure
func _ready():
	_update_lag()
	_update_size()
	_update_colors()
	_update_progress()

# @impure
func _process(delta: float):
	if $ProgressBarLag.size.x <= $ProgressBarCurrent.size.x:
		_lag_delay = lag_delay
		$ProgressBarLag.size.x = $ProgressBarCurrent.size.x
	if _lag_delay > 0.0:
		_lag_delay -= delta
	if _lag_delay <= 0.0:
		$ProgressBarLag.size.x = move_toward($ProgressBarLag.size.x, $ProgressBarCurrent.size.x, delta * lag_speed)

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
	$ProgressBarCurrent.size = Vector2(lerp(0.0, rect.size.x, progress), rect.size.y)

# @impure
func _update_colors():
	$Margin.color = margin_color
	$Background.color = background_color
	$ProgressBarLag.color = lag_color
	$ProgressBarCurrent.color = color

# @impure
func _update_progress():
	var rect := get_rect()
	$ProgressBarCurrent.size = Vector2(lerp(0.0, rect.size.x, progress), rect.size.y)

# @signal
# @impure
func _on_resized():
	_update_size()
