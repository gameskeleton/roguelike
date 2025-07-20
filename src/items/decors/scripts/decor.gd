extends Node2D

@export var debris_scene: PackedScene
@export var coin_spawn_position: Node2D

@export_group("Nodes")
@export var audio_stream_player: AudioStreamPlayer

var _broken := false

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _from_source: Node, _from_instigator: Node):
	if _broken:
		return
	hide()
	_broken = true
	RkObjectSpawner.spawn_coin(self, (self if not coin_spawn_position else coin_spawn_position).global_position).fly()
	if debris_scene:
		var debris: Node2D = debris_scene.instantiate()
		debris.position = position
		get_parent().add_child(debris)
	if audio_stream_player:
		audio_stream_player.play()
		await audio_stream_player.finished
	queue_free()
