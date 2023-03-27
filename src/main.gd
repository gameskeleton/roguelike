extends Control

const ROOM_WIDTH := 512.0
const ROOM_HEIGHT := 288.0

var current_room := Vector2(0.0, 0.0)

func _ready():
	$Player/Camera2D.reset_smoothing()

func _process(delta: float):
	# gui update
	$CanvasLayer/State.text = $Player.fsm.current_state_node.name
	$CanvasLayer/StaminaMeter.progress = move_toward($CanvasLayer/StaminaMeter.progress, $Player.get_stamina(), delta)
	# room camera
	if $Player.position.x > (current_room.x * ROOM_WIDTH) + ROOM_WIDTH:
		current_room.x += 1
		_restrict_camera()
	if $Player.position.x < current_room.x * ROOM_WIDTH:
		current_room.x -= 1
		_restrict_camera()
	if $Player.position.y > (current_room.y * ROOM_HEIGHT) + ROOM_HEIGHT:
		current_room.y += 1
		_restrict_camera()
	if $Player.position.y < current_room.y * ROOM_HEIGHT:
		current_room.y -= 1
		_restrict_camera()

func _restrict_camera():
	$Player/Camera2D.limit_top = current_room.y * ROOM_HEIGHT
	$Player/Camera2D.limit_left = current_room.x * ROOM_WIDTH
	$Player/Camera2D.limit_right = current_room.x * ROOM_WIDTH + ROOM_WIDTH
	$Player/Camera2D.limit_bottom = current_room.y * ROOM_HEIGHT + ROOM_HEIGHT
