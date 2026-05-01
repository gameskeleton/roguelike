extends Node2D

@export_group(&"Audio")
@export var break_audio_stream: AudioStream

@export_group(&"Scenes")
@export var debris_scene: PackedScene

@export_group(&"References")
@export var coin_spawn_position: Node2D

var _broken := false

# @impure
func _ready() -> void:
	# references
	assert(debris_scene != null, "debris_scene not set")
	assert(break_audio_stream != null, "break_audio_stream not set")
	assert(coin_spawn_position != null, "coin_spawn_position not set")

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _from_source: Node, _from_instigator: Node) -> void:
	if _broken:
		return
	hide()
	_broken = true
	RkObjectSpawner.spawn_coin(self, (self if not coin_spawn_position else coin_spawn_position).global_position).fly()
	RkObjectSpawner.spawn_experience(self, (self if not coin_spawn_position else coin_spawn_position).global_position).fly()
	if debris_scene:
		var debris: Node2D = debris_scene.instantiate()
		debris.global_position = global_position
		get_parent().add_child(debris)
	if break_audio_stream:
		RkAudioSpawner.play_unique_2d(RkAudioSpawner.SFXBus, global_position, break_audio_stream, scene_file_path)
	queue_free()
