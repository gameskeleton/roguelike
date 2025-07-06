@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("RkCamera2D", "Camera2D", preload("res://addons/net.rootkernel.camera/src/camera_2d.gd"), preload("res://addons/net.rootkernel.camera/plugin.svg"))
	add_custom_type("RkCameraRegion2D", "ColorRect", preload("res://addons/net.rootkernel.camera/src/camera_region_2d.gd"), preload("res://addons/net.rootkernel.camera/plugin.svg"))

func _exit_tree() -> void:
	remove_custom_type("RkCameraRegion2D")
	remove_custom_type("RkCamera2D")
