class_name RkBufferedInput

var _action: StringName
var _buffer_time := 0.0
var _buffer_remaining := 0.0

# @impure
func _init(action: StringName, buffer_time := 0.0):
	_action = action
	_buffer_time = buffer_time

# @impure
func process(delta: float):
	_buffer_remaining = clampf(_buffer_remaining - delta, 0.0, _buffer_time)
	if Input.is_action_just_pressed(_action):
		_buffer_remaining = _buffer_time

# @impure
func consume():
	_buffer_remaining = 0.0

# @pure
func is_down() -> bool:
	return Input.is_action_pressed(_action)

# @pure
func is_pressed() -> bool:
	return Input.is_action_just_pressed(_action) or _buffer_remaining > 0.0

# @pure
func to_down_int() -> int:
	return 1 if is_down() else 0

# @pure
func to_pressed_int() -> int:
	return 1 if is_pressed() else 0
