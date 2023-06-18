@tool
extends RigidBody2D
class_name RkPickupItem

const PICKUP_DELAY := 0.35

@onready var player_detector: Area2D = $PlayerDetector

@export var item: RkItemRes :
	get: return item
	set(new_item):
		item = new_item
		name = item.name
		$Sprite2D.texture = new_item.icon
		($Sprite2D.material as ShaderMaterial).set_shader_parameter("tint", item.color)

# @impure
func _ready():
	# enable pickup after a while
	await get_tree().create_timer(PICKUP_DELAY, false).timeout
	player_detector.monitoring = true
	player_detector.monitorable = true

# @impure
func fly(direction := Vector2.UP, cone := 35.0, strength := Vector2(180.0, 200.0)) -> RkPickupItem:
	var half_cone := cone * 0.5
	apply_central_impulse(randf_range(strength.x, strength.y) * direction.rotated(deg_to_rad(randf_range(-half_cone, +half_cone))))
	return self

# @signal
# @impure
func _on_player_detector_body_entered(body: Node2D):
	if body is RkPlayer:
		body.inventory_system.add_item(item)
		queue_free()
