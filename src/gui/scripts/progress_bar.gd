@tool
extends Control
class_name RkGuiProgressBar

@export var color := Color.GREEN :
	get:
		return color
	set(value):
		color = value
		_update_colors()
@export var margin_color := Color.GOLD :
	get:
		return margin_color
	set(value):
		margin_color = value
		_update_colors()
@export var background_color := Color.WHITE :
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

# @impure
func _ready():
	_update_colors()
	_update_progress()

# @impure
func _update_colors():
	$Margin.color = margin_color
	$Background.color = background_color
	$ProgressBar.color = color

# @impure
func _update_progress():
	var rect := get_rect()
	$Margin.size = rect.size + margin * 2.0
	$Margin.position = -margin
	$Background.size = rect.size
	$ProgressBar.size = Vector2(lerp(0.0, rect.size.x, progress), rect.size.y)

# @signal
# @impure
func _on_resized():
	_update_progress()
