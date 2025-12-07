@tool
@icon("res://addons/net.rootkernel.camera/plugin.svg")
extends ColorRect
class_name RkCameraRegion2D

@export_tool_button("Fill screen", "Marker2D")
var fill_screen_button := _fill_screen

# @impure
func _init() -> void:
	add_to_group(RkCamera2D.CAMERA_REGION_GROUP_NAME, false)

# @impure
func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = false

# @impure
func _enter_tree() -> void:
	color = Color.from_rgba8(255, 255, 255, 50)

# @impure
func _fill_screen() -> void:
	if Engine.is_editor_hint():
		var interface = Engine.get_singleton("EditorInterface") # safe in exported build, whereas direct access to EditorInterface in a tool would crash the script
		var undo_redo := interface.get_editor_undo_redo() as UndoRedo
		var viewport_size := Vector2(
			ProjectSettings.get(&"display/window/size/viewport_width"),
			ProjectSettings.get(&"display/window/size/viewport_height"),
		)
		undo_redo.create_action("SmartCameraRegion2D: Fill screen")
		undo_redo.add_do_property(self, &"size", viewport_size)
		undo_redo.add_undo_property(self, &"size", size)
		undo_redo.commit_action()

# @pure
func get_bounds() -> Rect2:
	return Rect2(global_position, size)
