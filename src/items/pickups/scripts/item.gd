@tool
extends RigidBody2D

@export var item: RkInventoryItemRes :
	get: return item
	set(new_item):
		item = new_item
		name = item.name
		$Sprite2D.texture = new_item.icon
		($Sprite2D.material as ShaderMaterial).set_shader_parameter("tint", item.color)

# @signal
# @impure
func _on_player_detector_body_entered(body: Node2D):
	if body is RkPlayer:
		body.inventory_system.add_item(item)
		queue_free()
