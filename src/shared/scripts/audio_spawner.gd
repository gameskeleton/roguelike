class_name RkAudioSpawner extends Node

const SFXBus := &"SFX"
const MusicBus := &"Music"
const MasterBus := &"Master"

static var unique_streams_playing := PackedStringArray()

@export var spawn_node: Node

# @impure
func _ready() -> void:
	# references
	assert(spawn_node != null, "spawn_node not set")

# @impure
static func play_unique_2d(bus: StringName, global_position: Vector2, stream: AudioStream, unique_key: StringName, from_position := 0.0) -> bool:
	if unique_streams_playing.has(unique_key):
		return false
	var main_node := RkMain.get_main_node()
	var audio_stream_player := AudioStreamPlayer2D.new()
	main_node.audio_spawner_node.spawn_node.add_child(audio_stream_player)
	audio_stream_player.bus = bus
	audio_stream_player.stream = stream
	audio_stream_player.global_position = global_position
	audio_stream_player.finished.connect(func() -> void:
		audio_stream_player.queue_free()
		unique_streams_playing.erase(unique_key)
	, ConnectFlags.CONNECT_ONE_SHOT)
	audio_stream_player.play(from_position)
	unique_streams_playing.push_back(unique_key)
	return true
