extends RkStateMachineState

enum State {crouch_to_slide, slide, slide_to_crouch}

@export var slide_curve: Curve

@export_group(&"References")
@export var slide_audio_stream_player: AudioStreamPlayer

var _state := State.crouch_to_slide
var _offset := 0.0

func _ready() -> void:
	# references
	assert(slide_curve != null, "slide_curve not set")
	assert(slide_audio_stream_player != null, "slide_audio_stream_player not set")

func start_state() -> RkStateMachineState:
	_state = State.crouch_to_slide
	_offset = 0.0
	player_node.audio.play_sound_effect(slide_audio_stream_player, 0.0, 0.85, 0.9)
	player_node.animation.play_animation(&"crouch_to_slide")
	player_node.collision.set_slide_hitbox_active(true)
	player_node.stamina_system.consume(player_node.SLIDE_STAMINA_COST)
	return null

func process_state(delta: float) -> RkStateMachineState:
	_offset = clampf(_offset + delta, 0.0, slide_curve.max_domain)
	player_node.movement.dash(player_node.SLIDE_MAX_SPEED * slide_curve.sample_baked(_offset))
	player_node.movement.apply_gravity(delta)
	if player_node.is_on_wall() and _offset < 0.4 * slide_curve.max_domain:
		return player_node.fsm.state_nodes.bump_into_wall
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	match _state:
		State.crouch_to_slide:
			if player_node.animation.is_animation_finished():
				_state = State.slide
				player_node.animation.play_animation(&"slide")
		State.slide:
			if player_node.movement.is_stopped():
				_state = State.slide_to_crouch
				player_node.animation.play_animation(&"slide_to_crouch")
		State.slide_to_crouch:
			if player_node.animation.is_animation_finished():
				return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.crouch, player_node.fsm.state_nodes.bump_into_wall]):
		player_node.movement.uncrouch()
	player_node.collision.set_slide_hitbox_active(false)

func _on_slide_hitbox_area_entered(area: Area2D) -> void:
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.SLIDE_DAMAGE, RkLifePointsSystem.DmgType.slide)
