@tool
extends ColorRect

func _ready() -> void:
	_on_resized()
	if Engine.is_editor_hint():
		resized.connect(_on_resized)

func _on_resized() -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter(&"canvas_size", size)
