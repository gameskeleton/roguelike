@tool
extends Node2D
class_name RkWater2D

@export var color := Color(0.5, 0.5, 0.82, 0.59):
	set(value):
		color = value
		queue_redraw()
@export var width := 512:
	set(value):
		width = value
		queue_redraw()
@export var height := 288:
	set(value):
		height = value
		queue_redraw()
@export var spread := 0.25
@export var tension := 0.025
@export var damping := 0.025
@export var iterations := 2

@export_group("Collision")
@export_flags_2d_physics var collision_layer := 0
@export_flags_2d_physics var collision_mask := 0

var heights: PackedFloat32Array
var polygon: PackedVector2Array
var velocities: PackedFloat32Array
var left_deltas: PackedFloat32Array
var right_deltas: PackedFloat32Array
var accelerations: PackedFloat32Array

var area_2d_node: Area2D
var polygon_2d_node: Polygon2D
var collision_shape_2d: CollisionShape2D

static var body_enter := func (water: RkWater2D, body: Node2D):
	pass

# @impure
func splash(index: int, strength: float):
	assert(index >= 0 && index < width, "splash: index: 0 <= %s < %s" % [index, width])
	velocities[index] = strength

# @impure
func _draw():
	if Engine.is_editor_hint():
		draw_rect(Rect2(0, 0, width, height), color)

# @impure
func _ready():
	if Engine.is_editor_hint():
		return
	# preallocate
	heights.resize(width)
	heights.fill(0.0)
	polygon.resize(width + 3)
	polygon.fill(Vector2.ZERO)
	velocities.resize(width)
	velocities.fill(0.0)
	left_deltas.resize(width)
	left_deltas.fill(0.0)
	right_deltas.resize(width)
	right_deltas.fill(0.0)
	accelerations.resize(width)
	accelerations.fill(0.0)
	# create nodes
	area_2d_node = Area2D.new()
	polygon_2d_node = Polygon2D.new()
	collision_shape_2d = CollisionShape2D.new()
	add_child(area_2d_node)
	add_child(polygon_2d_node)
	area_2d_node.add_child(collision_shape_2d)
	polygon_2d_node.color = color
	# create collision shapes
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	collision_shape_2d.shape = shape
	collision_shape_2d.position = Vector2(width / 2.0, height / 2.0)
	area_2d_node.collision_mask = collision_mask
	area_2d_node.collision_layer = collision_layer
	area_2d_node.body_entered.connect(_on_body_entered)
	# add one control point to open the polygon
	polygon[0] = Vector2(0, 0)
	# add two control points to close the polygon
	polygon[width + 1] = Vector2(width, height)
	polygon[width + 2] = Vector2(0, height)

# @impure
func _process(delta: float):
	if Engine.is_editor_hint():
		return
	# apply spring force
	for i in range(width):
		accelerations[i] = - tension * heights[i] - velocities[i] * damping
		velocities[i] += accelerations[i]
		heights[i] += velocities[i]
	# propagate to neighbors
	for j in range(iterations):
		for i in range(width):
			if i > 0:
				left_deltas[i] = spread * (heights[i] - heights[i - 1])
				velocities[i - 1] += left_deltas[i]
			if i < width - 1:
				right_deltas[i] = spread * (heights[i] - heights[i + 1])
				velocities[i + 1] += right_deltas[i]
		for i in range(width):
			if i > 0:
				heights[i - 1] += left_deltas[i]
			if i < width - 1:
				heights[i + 1] += right_deltas[i]
	# clamp the heights and update the polygon
	for x in range(width):
		var half_height := height * 0.5
		heights[x] = clampf(heights[x], -half_height, half_height)
		polygon[x + 1] = Vector2(x + 1, heights[x])
	polygon_2d_node.uv = polygon
	polygon_2d_node.polygon = polygon

# @signal
# @impure
func _on_body_entered(body: Node2D):
	RkWater2D.body_enter.call(self, body)
