@tool
extends Node2D

@export var length := 5:
	set(value):
		length = value
		if Engine.is_editor_hint():
			_create_chain()
@export var chain_link_size := Vector2(4, 6):
	set(value):
		chain_link_size = value
		if Engine.is_editor_hint():
			_create_chain()
@export var chain_link_texture: Texture2D:
	set(value):
		chain_link_texture = value
		if Engine.is_editor_hint():
			_create_chain()
@export var last_chain_link_texture: Texture2D:
	set(value):
		last_chain_link_texture = value
		if Engine.is_editor_hint():
			_create_chain()
@export var freeze_first_chain_link := false:
	set(value):
		freeze_first_chain_link = value
		if Engine.is_editor_hint():
			_create_chain()
@export_flags_2d_physics var chain_link_collision_mask: int:
	set(value):
		chain_link_collision_mask = value
		if Engine.is_editor_hint():
			_create_chain()
@export_flags_2d_physics var chain_link_collision_layer: int:
	set(value):
		chain_link_collision_layer = value
		if Engine.is_editor_hint():
			_create_chain()
@export_flags_2d_physics var last_chain_link_collision_mask: int:
	set(value):
		last_chain_link_collision_mask = value
		if Engine.is_editor_hint():
			_create_chain()
@export_flags_2d_physics var last_chain_link_collision_layer: int:
	set(value):
		last_chain_link_collision_layer = value
		if Engine.is_editor_hint():
			_create_chain()

@onready var chain_base := $Base as StaticBody2D
@onready var chain_links := $Links as Node2D
@onready var audio_stream_player := $AudioStreamPlayer2D as AudioStreamPlayer2D

var _chain_link_circle_shape := CircleShape2D.new()

# @impure
func _ready():
	_create_chain()

# @impure
func _create_chain():
	if length < 1 or not chain_base or not chain_links:
		return
	var pin_joints: Array[PinJoint2D] = []
	var chain_link_rigid_bodies: Array[RigidBody2D] = []
	RkUtils.clear_node_children(chain_links)
	_chain_link_circle_shape.radius = 3.0
	chain_base.collision_mask = chain_link_collision_mask
	chain_base.collision_layer = chain_link_collision_layer
	# create chain links and pin joints.
	for i in length:
		var last := i == length - 1
		var pin_joint := PinJoint2D.new()
		var chain_link_sprite := Sprite2D.new()
		var chain_link_rigid_body := RigidBody2D.new()
		var chain_link_collision_shape := CollisionShape2D.new()
		#
		pin_joint.bias = 0.0
		pin_joint.visible = false
		pin_joint.softness = 0.0
		pin_joint.position = Vector2(0, chain_link_size.y * i)
		pin_joint.disable_collision = true
		chain_link_sprite.texture = chain_link_texture if not last or not last_chain_link_texture else last_chain_link_texture
		chain_link_sprite.centered = false
		chain_link_rigid_body.position = Vector2(-chain_link_size.x * 0.5, -chain_link_size.y + chain_link_size.y * (i + 1))
		chain_link_rigid_body.linear_damp = 1.5
		chain_link_rigid_body.angular_damp = 1.5
		chain_link_rigid_body.gravity_scale = 1.1
		chain_link_rigid_body.collision_mask = chain_link_collision_mask if not last else last_chain_link_collision_mask
		chain_link_rigid_body.collision_layer = chain_link_collision_layer if not last else last_chain_link_collision_layer
		chain_link_collision_shape.shape = _chain_link_circle_shape
		chain_link_collision_shape.position = Vector2(chain_link_size.x * 0.5, chain_link_size.y * 0.5)
		#
		chain_links.add_child(pin_joint)
		chain_links.add_child(chain_link_rigid_body)
		chain_link_rigid_body.add_child(chain_link_sprite)
		chain_link_rigid_body.add_child(chain_link_collision_shape)
		#
		pin_joints.push_back(pin_joint)
		chain_link_rigid_bodies.push_back(chain_link_rigid_body)
		#
		if last:
			chain_link_rigid_body.contact_monitor = true
			chain_link_rigid_body.max_contacts_reported = 1
			chain_link_rigid_body.body_entered.connect(func(body: Node):
				if body is RkPlayer and not audio_stream_player.playing:
					audio_stream_player.pitch_scale = randf_range(0.95, 1.05)
					audio_stream_player.play()
			)
	# link pin joints to chain links.
	for i in length:
		if i == 0:
			pin_joints[i].node_a = chain_base.get_path()
			pin_joints[i].node_b = chain_link_rigid_bodies[i].get_path()
		else:
			pin_joints[i].node_a = chain_link_rigid_bodies[i - 1].get_path()
			pin_joints[i].node_b = chain_link_rigid_bodies[i].get_path()
	# freeze the first chain link if enabled.
	if freeze_first_chain_link:
		chain_link_rigid_bodies[0].freeze = true
