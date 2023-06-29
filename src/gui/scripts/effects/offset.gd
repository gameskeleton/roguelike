@tool
extends RichTextEffectBase
class_name RichTextEffectOffset

var bbcode = "offset"

# @impure
func _init():
	resource_name = "RichTextEffectOffset"

# @impure
func _process_custom_fx(char_fx: CharFXTransform):
	var x: float = char_fx.env.get("x", 0.0)
	var y: float = char_fx.env.get("y", 8.0)
	char_fx.offset.x = x
	char_fx.offset.y = y
	return true
