@tool
extends RichTextEffectBase
class_name RichTextEffectBounce

var bbcode = "bounce"

func _init():
	resource_name = "RichTextEffectBounce"

func _process_custom_fx(char_fx: CharFXTransform):
	var freq: float = char_fx.env.get("freq", 15.0)
	char_fx.offset.y = 2.0 * sin(char_fx.relative_index + char_fx.elapsed_time * freq)
	return true
