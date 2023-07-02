extends ColorRect
class_name RkGuiInventoryCellDrop

@export var inventory: RkGuiInventory

# @impure
func _drop_data(_at_position: Vector2, data: Variant):
	inventory.drop_item_or_slot(data.from_type, data.from_index)

# @pure
func _can_drop_data(_at_position: Vector2, data: Variant):
	return data is Dictionary and data.has("item") and data.has("from_type") and data.has("from_index")
