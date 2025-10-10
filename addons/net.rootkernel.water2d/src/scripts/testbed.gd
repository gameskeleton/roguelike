extends Node2D

@export var strength := -100.0
@export var water_node: RkWater2D

# @impure
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			water_node.width += 16
			return
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			water_node.width -= 16
			return
		var mouse_pos := get_global_mouse_position()
		var local_pos := mouse_pos - water_node.global_position
		var x_pos_int := int(local_pos.x)
		if x_pos_int >= 0 and x_pos_int < water_node.width:
			print("React at position: ", x_pos_int)
			water_node.react(x_pos_int, -100.0)
