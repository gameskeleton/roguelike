@tool
@icon("res://addons/net.rootkernel.camera/plugin.svg")
extends Camera2D
class_name RkCamera2D

const CAMERA_REGION_GROUP_NAME := &"rk_camera_region_2d"

@export var target_node: Node2D:
	set(value):
		target_node = value
		set_physics_process(target_node and not Engine.is_editor_hint())
		update_configuration_warnings()

func _init() -> void:
	if ProjectSettings.get(&"physics/common/physics_interpolation"):
		process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS

func _notification(_what: int) -> void:
	set_physics_process(target_node and not Engine.is_editor_hint())
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not target_node:
		return ["Missing a target_node"]
	return []

##
# Camera
##

var _target_bounds: Rect2
var _camera_region: RkCameraRegion2D
var _camera_regions: Array[RkCameraRegion2D] = []

func _ready() -> void:
	if not target_node or Engine.is_editor_hint():
		return
	var nodes := get_tree().get_nodes_in_group(CAMERA_REGION_GROUP_NAME)
	for node in nodes:
		assert(node is RkCameraRegion2D, "%s is in the %s group, but is not a RkCameraRegion2D" % [node.name, CAMERA_REGION_GROUP_NAME])
		var camera_region := node as RkCameraRegion2D
		for other_camera_region in _camera_regions:
			if camera_region.get_bounds().intersects(other_camera_region.get_bounds()):
				push_error("%s intersects with %s" % [camera_region.name, other_camera_region.name])
		_camera_regions.push_back(camera_region as RkCameraRegion2D)
		if not camera_region and camera_region.get_bounds().has_point(target_node.global_position):
			_camera_region = camera_region
			enable_camera_region(camera_region)
	position = target_node.global_position
	reset_smoothing.call_deferred()

func _process(delta: float) -> void:
	position = target_node.global_position
	for smart_region in _camera_regions:
		if smart_region == _camera_region:
			continue
		var bounds := smart_region.get_bounds()
		if bounds.has_point(target_node.global_position):
			_camera_region = smart_region
			enable_camera_region(_camera_region)
			return
	if not _target_bounds:
		return
	limit_top = ceili(move_toward(limit_top, _target_bounds.position.y, 600.0 * delta))
	limit_left = ceili(move_toward(limit_left, _target_bounds.position.x, 600.0 * delta))
	limit_right = ceili(move_toward(limit_right, _target_bounds.position.x + _target_bounds.size.x, 600.0 * delta))
	limit_bottom = ceili(move_toward(limit_bottom, _target_bounds.position.y + _target_bounds.size.y, 600.0 * delta))

func enable_camera_region(camera_region: RkCameraRegion2D) -> void:
	var bounds := camera_region.get_bounds()
	if not _target_bounds:
		limit_top = ceili(bounds.position.y)
		limit_left = ceili(bounds.position.x)
		limit_right = ceili(bounds.position.x + bounds.size.x)
		limit_bottom = ceili(bounds.position.y + bounds.size.y)
		reset_smoothing.call_deferred()
	_target_bounds = bounds
