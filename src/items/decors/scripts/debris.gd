extends Node2D

const FADE_OUT_SPEED := 1.0

@export var force := 200.0
@export var pieces: Array[RigidBody2D]

var _fade_out := 1.0
var _start_fade_out := 2.0

# @impure
func _ready() -> void:
	# references
	assert(pieces != null, "pieces not set")
	# apply impulse to pieces
	for piece in pieces:
		piece.angular_velocity = randf_range(5.0, 10.0)
		piece.apply_central_impulse(Vector2.UP.rotated(deg_to_rad(randf_range(-25.0, +25.0))) * force)

# @impure
func _process(delta: float) -> void:
	if _start_fade_out > 0:
		_start_fade_out -= delta * FADE_OUT_SPEED
		return
	modulate.a = _fade_out
	_fade_out -= delta * FADE_OUT_SPEED
	if _fade_out <= 0:
		queue_free()
