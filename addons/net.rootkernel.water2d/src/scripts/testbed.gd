extends Node2D

@onready var water: RkWater2D = $Water2D

# @impure
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			water.width += 16
			return
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			water.width -= 16
			return
		var mouse_pos := get_global_mouse_position()
		var local_pos := mouse_pos - water.global_position
		var x_pos_int := int(local_pos.x)
		if x_pos_int >= 0 and x_pos_int < water.width:
			print("Splash at position: ", x_pos_int)
			water.splash(x_pos_int, -100.0)
