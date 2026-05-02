extends RkStateMachineState

@export_group(&"References")
@export var hit_audio_stream_player: AudioStreamPlayer

enum State {hit_stand, hit_crouch}

var _state := State.hit_stand
var _tween: Tween

func _ready() -> void:
	# references
	assert(hit_audio_stream_player != null, "hit_audio_stream_player not set")

func start_state() -> RkStateMachineState:
	if player_node.crouched:
		_state = State.hit_crouch
		player_node.animation.play_animation(&"hit_crouch")
	else:
		_state = State.hit_stand
		player_node.animation.play_animation(&"hit_stand")
	_play_hit_effect()
	_apply_impulse_in_damage_direction()
	player_node.audio.play_sound_effect(hit_audio_stream_player)
	player_node.life_points_system.invincible += 1
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.WALK_DECELERATION)
	if player_node.animation.is_animation_finished():
		match _state:
			State.hit_stand:
				return player_node.fsm.state_nodes.stand
			State.hit_crouch:
				return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	player_node.life_points_system.invincible -= 1
	_stop_hit_effect()

func _play_hit_effect() -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween().set_loops()
	_tween.tween_property(player_node.sprite, ^"self_modulate", Color.RED, 0.1)
	_tween.tween_property(player_node.sprite, ^"self_modulate", Color.WHITE, 0.1)

func _stop_hit_effect() -> void:
	_tween.kill()
	_tween = null
	player_node.sprite.self_modulate = Color.WHITE

func _apply_impulse_in_damage_direction() -> void:
	player_node.velocity = Vector2(-player_node.direction * player_node.HIT_IMPULSE.x, player_node.HIT_IMPULSE.y)
