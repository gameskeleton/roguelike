extends Control

var current_room := Vector2(0, 0)

func _ready():
	$Player/Camera2D.reset_smoothing()

func _process(_delta: float):
	if $Player.position.x > (current_room.x * 512) + 512:
		current_room.x += 1
		_restrict_camera()
	if $Player.position.x < current_room.x * 512:
		current_room.x -= 1
		_restrict_camera()
	if $Player.position.y > (current_room.y * 288) + 288:
		current_room.y += 1
		_restrict_camera()
	if $Player.position.y < current_room.y * 288:
		current_room.y -= 1
		_restrict_camera()

func _restrict_camera():
	$Player/Camera2D.limit_top = current_room.y * 288
	$Player/Camera2D.limit_left = current_room.x * 512
	$Player/Camera2D.limit_right = current_room.x * 512 + 512
	$Player/Camera2D.limit_bottom = current_room.y * 288 + 288
