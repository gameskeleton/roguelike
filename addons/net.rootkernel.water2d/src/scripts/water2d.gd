@tool
extends Node2D
class_name RkWater2D

@export var color := Color(0.5, 0.5, 0.82, 0.59):
	set(value):
		color = value
		if shader_material and is_inside_tree() and not Engine.is_editor_hint():
			shader_material.set_shader_parameter(&"water_color", color)
		queue_redraw()
@export var width := 512:
	set(value):
		assert(value > 0, "width must be strictly positive")
		width = value
		if is_inside_tree() and not Engine.is_editor_hint():
			_update_width()
			_update_mesh_and_collision()
		queue_redraw()
@export var height := 288:
	set(value):
		assert(value > 0, "height must be strictly positive")
		height = value
		if is_inside_tree() and not Engine.is_editor_hint():
			_update_mesh_and_collision()
		queue_redraw()
@export var spread := 0.25
@export var tension := 0.025
@export var damping := 0.025
@export var iterations := 1

@export_group("Collision")
@export_flags_2d_physics var collision_layer := 0
@export_flags_2d_physics var collision_mask := 0

var heights: PackedFloat32Array
var velocities: PackedFloat32Array
var left_deltas: PackedFloat32Array
var right_deltas: PackedFloat32Array
var accelerations: PackedFloat32Array

var area_2d_node: Area2D
var mesh_instance_2d: MeshInstance2D
var collision_shape_2d: CollisionShape2D

var heights_image: Image
var heights_texture: ImageTexture
var shader_material: ShaderMaterial

# @pure
static var body_enter := func(water: RkWater2D, body: Node2D):
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
	mesh_instance_2d = MeshInstance2D.new()
	collision_shape_2d = CollisionShape2D.new()
	add_child(area_2d_node)
	add_child(mesh_instance_2d)
	area_2d_node.add_child(collision_shape_2d)
	mesh_instance_2d.position = Vector2(width / 2.0, 0.0)
	# create quad mesh
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(width, height * 2.0)
	mesh_instance_2d.mesh = quad_mesh
	# create shader material
	shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://addons/net.rootkernel.water2d/src/shaders/water2d.gdshader")
	shader_material.set_shader_parameter(&"water_color", color)
	mesh_instance_2d.material = shader_material
	# create collision shapes
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	collision_shape_2d.shape = shape
	collision_shape_2d.position = Vector2(width / 2.0, height / 2.0)
	area_2d_node.collision_mask = collision_mask
	area_2d_node.collision_layer = collision_layer
	area_2d_node.body_entered.connect(_on_body_entered)
	# create heights texture
	heights_image = Image.create_empty(width, 1, false, Image.FORMAT_RF)
	heights_texture = ImageTexture.create_from_image(heights_image)
	_update_heights_texture()

# @impure
func _process(delta: float):
	if Engine.is_editor_hint():
		return
	# apply spring force with edge dampening
	for i in range(width):
		# calculate edge dampening factor (stronger near edges)
		var edge_distance := minf(i, width - 1 - i)
		var edge_dampening := 1.0
		var edge_dampening_zone := width * 0.01
		if edge_distance < edge_dampening_zone:
			edge_dampening = 0.3 + 0.7 * (edge_distance / edge_dampening_zone)
		# apply spring force with edge dampening
		var effective_damping := damping + (1.0 - edge_dampening) * 0.05
		accelerations[i] = - tension * heights[i] - velocities[i] * effective_damping
		velocities[i] += accelerations[i]
		heights[i] += velocities[i]
		# apply edge dampening to height and velocity
		heights[i] *= edge_dampening
		velocities[i] *= edge_dampening
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
	# clamp the heights
	for x in range(width):
		var half_height := height * 0.5
		heights[x] = clampf(heights[x], -half_height, half_height)
	# update heights texture
	_update_heights_texture()

# @impure
func _update_width():
	heights.resize(width)
	heights.fill(0.0)
	velocities.resize(width)
	velocities.fill(0.0)
	left_deltas.resize(width)
	left_deltas.fill(0.0)
	right_deltas.resize(width)
	right_deltas.fill(0.0)
	accelerations.resize(width)
	accelerations.fill(0.0)
	# recreate height texture with new width
	heights_image.resize(width, 1, Image.INTERPOLATE_NEAREST)
	heights_texture.set_image(heights_image)
	_update_heights_texture()

# @impure
func _update_heights_texture():
	# update the heights image
	for x in range(width):
		var normalized_height := (heights[x] + height * 0.5) / height
		normalized_height = clampf(normalized_height, 0.0, 1.0)
		heights_image.set_pixel(x, 0, Color(normalized_height, 0.0, 0.0, 1.0))
	# update the texture and shader
	heights_texture.update(heights_image)
	shader_material.set_shader_parameter(&"wave_heights", heights_texture)

# @impure
func _update_mesh_and_collision():
	var quad_mesh := mesh_instance_2d.mesh as QuadMesh
	var rect_shape := collision_shape_2d.shape as RectangleShape2D
	quad_mesh.size = Vector2(width, height)
	rect_shape.size = Vector2(width, height)
	mesh_instance_2d.position = Vector2(width / 2.0, height / 2.0)
	collision_shape_2d.position = Vector2(width / 2.0, height / 2.0)

# @signal
# @impure
func _on_body_entered(body: Node2D):
	RkWater2D.body_enter.call(self, body)
