class_name RkBufferedInput

var _name := ""
var _pressed := false
var _pressed_once := false
var _pressed_ticks_msec := 0.0

# @impure
func _init(name := "unnamed input"):
	_name = name

# @impure
func consume():
	_pressed = false
	_pressed_ticks_msec = 0.0

# @impure
func process(_delta: float, pressed: bool):
	if pressed:
		_pressed_once = true
		if not _pressed:
			_pressed = true
			_pressed_ticks_msec = Time.get_ticks_msec()
	else:
		_pressed = false

# @pure
func is_pressed() -> bool:
	return _pressed

# @pure
func is_just_pressed(grace_msec := 220.0) -> bool:
	if _pressed_once and _pressed_ticks_msec > Time.get_ticks_msec() - grace_msec:
		#if not _pressed:
		#	print("is_just_pressed: %s pressed in grace period" % [_name])
		return true
	return false
