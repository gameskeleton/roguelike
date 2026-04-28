class_name RkPlayerInput

var player_node: RkPlayer

var up := RkBufferedInput.new(&"player_up", 0.1)
var down := RkBufferedInput.new(&"player_down", 0.1)
var left := RkBufferedInput.new(&"player_left", 0.0)
var right := RkBufferedInput.new(&"player_right", 0.0)
var jump := RkBufferedInput.new(&"player_jump", 0.1)
var roll := RkBufferedInput.new(&"player_roll", 0.1)
var slide := RkBufferedInput.new(&"player_slide", 0.1)
var attack := RkBufferedInput.new(&"player_attack", 0.1)
var velocity := Vector2.ZERO

# @impure
func _init(_player_node: RkPlayer) -> void:
	player_node = _player_node

# @impure
func process(delta: float) -> void:
	up.process(delta)
	down.process(delta)
	left.process(delta)
	right.process(delta)
	jump.process(delta)
	roll.process(delta)
	slide.process(delta)
	attack.process(delta)
	velocity = Vector2(right.to_down_int() - left.to_down_int(), down.to_down_int() - up.to_down_int())

# @pure
func has_horizontal_input() -> bool:
	return velocity.x != 0.0
