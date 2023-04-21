extends Control
class_name RkGuiInventoryCell

@export var item: RkInventoryItemRes :
	get: return item
	set(value):
		item = value
		texture_rect.texture = value.icon if value else null
		texture_rect.visible = true
@export var type := RkInventorySystem.ItemType.slot
@export var inventory: RkGuiInventory

@onready var texture_rect: TextureRect = $TextureRect

# @impure
func _get_drag_data(_at_position: Vector2):
	var texture := texture_rect.texture
	var drag_item := item
	var drag_texture_rect := TextureRect.new()
	texture_rect.visible = false
	drag_texture_rect.texture = texture
	drag_texture_rect.custom_minimum_size = Vector2(16.0, 16.0)
	set_drag_preview(drag_texture_rect)
	return {
		item = drag_item,
		from_type = type,
		from_index = get_index(),
	}

# @pure
func _can_drop_data(_at_position: Vector2, data: Variant):
	return data is Dictionary and data.has("item") and data.has("from_type") and data.has("from_index")

# @impure
func _drop_data(_at_position: Vector2, data: Variant):
	inventory.move_item_or_slot(data.from_type, data.from_index, type, get_index())