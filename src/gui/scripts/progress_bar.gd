@tool
extends Control

@export var color := Color.GREEN :
	get:
		return color
	set(value):
		color = value
		_update_colors()
@export var bg_color := Color.WHITE :
	get:
		return bg_color
	set(value):
		bg_color = value
		_update_colors()
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
	$Bg.color = bg_color
	$Progress.color = color

# @impure
func _update_progress():
	var rect := get_rect()
	$Progress.size = Vector2(lerp(0.0, rect.size.x, progress), rect.size.y)

# @signal
# @impure
func _on_resized():
	_update_progress()
