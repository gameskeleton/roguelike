@tool
class_name RkTeleporter extends Area2D

enum Direction { left, right }

@export var id := &"":
	get: return id
	set(value):
		if id == value:
			return
		id = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
@export var shape: CollisionShape2D:
	get: return shape
	set(value):
		shape = value
		if Engine.is_editor_hint():
			update_configuration_warnings()
@export var target: RkTeleportTarget:
	get: return target
	set(value):
		if target == value:
			return
		if target and Engine.is_editor_hint():
			target.changed.disconnect(_on_target_changed)
		target = value
		if target and Engine.is_editor_hint():
			target.changed.connect(_on_target_changed)
			update_configuration_warnings()
@export var direction := Direction.left:
	get: return direction
	set(value):
		if direction == value:
			return
		direction = value
		if Engine.is_editor_hint():
			queue_redraw()
			update_configuration_warnings()
@export var direction_limit := 8:
	get: return direction_limit
	set(value):
		if direction_limit == value:
			return
		direction_limit = value
		if Engine.is_editor_hint():
			queue_redraw()
			update_configuration_warnings()

var _rect: Rect2
var _player_node: RkPlayer

var direction_limit_offset: Vector2:
	get: return Vector2(direction_limit if direction == Direction.right else -direction_limit, 0.0)

# @impure
func _ready() -> void:
	# references.
	assert(target != null, "target not set")
	# draw limits.
	if Engine.is_editor_hint():
		queue_redraw()
	# store the bounding rect of the teleporter.
	_rect = shape.shape.get_rect()
	# only sample while a player overlaps this teleporter.
	set_physics_process(false)

# @impure
func _draw() -> void:
	# we only draw the teleporter hard limit in the editor
	if not Engine.is_editor_hint():
		return
	# compute the position by taking the collision shape bbox
	var top_center := -Vector2(0, _rect.size.y / 2.0) + direction_limit_offset
	var bottom_center := Vector2(0, _rect.size.y / 2.0) + direction_limit_offset
	draw_line(top_center, bottom_center, Color.DARK_RED, 2.0)

# @impure
func _enter_tree() -> void:
	# only sample while a player overlaps this teleporter.
	set_physics_process(false)

# @impure
func _physics_process(_delta: float) -> void:
	if not _player_node:
		return
	var center := position + _rect.get_center() + direction_limit_offset
	match direction:
		Direction.left: if _player_node.position.x <= center.x:
			target.teleport.call_deferred(self, _player_node)
			_player_node = null
			set_physics_process(false)
		Direction.right: if _player_node.position.x >= center.x:
			target.teleport.call_deferred(self, _player_node)
			_player_node = null
			set_physics_process(false)

# @pure
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if id == null or id.is_empty():
		warnings.push_back("id must be set")
	warnings.append_array(target.get_configuration_warnings(self))
	return warnings

# @signal
# @impure
func _on_body_entered(body: PhysicsBody2D) -> void:
	assert(body is RkPlayer, "body must be a RkPlayer")
	_player_node = body as RkPlayer
	set_physics_process(true)

# @signal
# @impure
func _on_body_exited(body: PhysicsBody2D) -> void:
	assert(body is RkPlayer, "body must be a RkPlayer")
	_player_node = null
	set_physics_process(false)

# @signal
# @impure
func _on_target_changed() -> void:
	update_configuration_warnings()

# @pure
func offset_position(to_position: Vector2) -> Vector2:
	return position + direction_limit_offset - to_position

# find_level_node walks up the tree to find the level this teleporter belongs to.
# @pure
func find_level_node() -> RkLevel:
	var node := get_parent()
	while node != null:
		if node is RkLevel:
			return node as RkLevel
		node = node.get_parent()
	return null

# @pure
func get_teleporter_nodes(in_level_node: RkLevel) -> Array[RkTeleporter]:
	var teleporters: Array[RkTeleporter] = []
	for teleporter in in_level_node.find_child("Teleporters").get_children():
		if teleporter is RkTeleporter:
			teleporters.push_back(teleporter)
	return teleporters

# @pure
func find_teleporter_node(in_level_node: RkLevel, teleporter_id: StringName) -> RkTeleporter:
	var teleporters := get_teleporter_nodes(in_level_node)
	var teleporter_index := teleporters.find_custom(func (teleporter: RkTeleporter): return teleporter.id == teleporter_id)
	return teleporters[teleporter_index] if teleporter_index != -1 else null
