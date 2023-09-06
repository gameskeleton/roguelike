extends RigidBody2D
class_name RkPickupExperience

const PICKUP_DELAY := 0.35

@export var value := 1

var _picked_up := false

# @impure
func fly(direction := Vector2.UP, cone := 35.0, strength := Vector2(150.0, 180.0)) -> RkPickupExperience:
	var half_cone := cone * 0.5
	apply_central_impulse(randf_range(strength.x, strength.y) * direction.rotated(deg_to_rad(randf_range(-half_cone, +half_cone))))
	return self

# @impure
func _ready():
	# enable pickup after a while
	await get_tree().create_timer(PICKUP_DELAY, false).timeout
	$PlayerDetector.monitoring = true
	$PlayerDetector.monitorable = true

# @impure
func _process(_delta: float):
	var line := $Node/Line2D
	if linear_velocity.length_squared() > 2:
		line.add_point(global_position)
		while line.get_point_count() > 20:
			line.remove_point(0)
	else:
		line.clear_points()

# @impure
func _pick_up(player: RkPlayer):
	if not _picked_up:
		hide()
		player.level_system.earn_experience(value)
		_picked_up = true
		if not player.experience_picked_up_audio_stream_player.playing or player.experience_picked_up_audio_stream_player.get_playback_position() > 0.03:
			player.experience_picked_up_audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
			player.experience_picked_up_audio_stream_player.play()
		await get_tree().create_timer(1.0, false).timeout
		queue_free()

# @signal
# @impure
func _on_body_entered(body: Node2D):
	if not _picked_up and body is TileMap and linear_velocity.length() >= 6.0 and not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.pitch_scale = randf_range(0.95, 1.05)
		$AudioStreamPlayer.play(0.1)

# @signal
# @impure
func _on_player_detector_body_entered(body: Node2D):
	if body is RkPlayer:
		_pick_up(body)
