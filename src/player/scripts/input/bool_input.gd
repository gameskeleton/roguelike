class_name RkBoolInput

var _name := ""
var _pressed := false
var _just_pressed := false

# @impure
func _init(name := "unnamed input"):
	_name = name

# @impure
func process(_delta: float, pressed: bool):
	if pressed and not _pressed and not _just_pressed:
		_just_pressed = true
	else:
		_just_pressed = false
	_pressed = pressed

# @pure
func is_pressed() -> bool:
	return _pressed

# @pure
func to_pressed_int() -> int:
	return 1 if is_pressed() else 0

# @pure
func is_just_pressed() -> bool:
	return _just_pressed

# @pure
func to_just_pressed_int() -> int:
	return 1 if is_just_pressed() else 0
