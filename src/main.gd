extends Control
class_name RkMain

const ROOM_WIDTH := 512.0
const ROOM_HEIGHT := 288.0

var current_room := Vector2()

func _ready():
	$Player/Camera2D.reset_smoothing()

func _process(delta: float):
	# gui update
	$CanvasLayer/State.text = $Player.fsm.current_state_node.name
	$CanvasLayer/StaminaMeter.progress = move_toward($CanvasLayer/StaminaMeter.progress, $Player.get_stamina(), delta)
	# room camera
	current_room.x = floor($Player.position.x / ROOM_WIDTH)
	current_room.y = floor($Player.position.y / ROOM_HEIGHT)
	$Player/Camera2D.limit_top = current_room.y * ROOM_HEIGHT
	$Player/Camera2D.limit_left = current_room.x * ROOM_WIDTH
	$Player/Camera2D.limit_right = (current_room.x + 1) * ROOM_WIDTH
	$Player/Camera2D.limit_bottom = (current_room.y + 1) * ROOM_HEIGHT
