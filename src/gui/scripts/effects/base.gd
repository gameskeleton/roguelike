@tool
extends RichTextEffect
class_name RichTextEffectBase

# @impure
func _init():
	resource_name = "RichTextEffectBase"

# @pure
func get_text_server() -> TextServer:
	return TextServerManager.get_primary_interface()

# @pure
func get_char_glyph_index(char_fx: CharFXTransform, char_string: String) -> int:
	return get_text_server().font_get_glyph_index(char_fx.font, 1, char_string.unicode_at(0), 0)

# @pure
func is_processing_character(char_fx: CharFXTransform, char_string: String) -> bool:
	return char_fx.glyph_index == get_char_glyph_index(char_fx, char_string)
