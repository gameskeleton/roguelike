@tool
extends Node2D
class_name RkChest

@export var delay := 0.05
@export var content: RkSpawnRes
@export_range(-1, 1, 2) var direction := -1 :
	get: return direction
	set(value):
		direction = value
		$AnimatedSprite2D.flip_h = value == 1
		$AnimatedSprite2D.offset.x = -14 if value == 1 else 0

var _opened := false
var _player_detected := false

# @impure
func _ready():
	set_process(false)

# @impure 
func _process(_delta: float):
	if content and not _opened and Input.is_action_just_pressed("player_up"):
		_opened = true
		$AnimatedSprite2D.play("open")
		$AudioStreamPlayer.pitch_scale = randf_range(0.95, 1.05)
		$AudioStreamPlayer.play()
	if _opened and $AnimatedSprite2D.frame > 5:
		content.spawn(self, global_position)
		set_process(false)

# @signal
# @impure
func _on_player_detector_body_entered(_body: Node2D):
	if not _opened:
		set_process(true)
	_player_detected = true

# @signal
# @impure
func _on_player_detector_body_exited(_body: Node2D):
	if not _opened:
		set_process(false)
	_player_detected = false
