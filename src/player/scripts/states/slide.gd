extends RkStateMachineState

enum State {crouch_to_slide, slide, slide_to_crouch}

@export var slide_curve: Curve

@export_group("Nodes")
@export var slide_audio_stream_player: AudioStreamPlayer

var _state := State.crouch_to_slide
var _offset := 0.0

func start_state():
	_state = State.crouch_to_slide
	_offset = 0.0
	player_node.play_animation("crouch_to_slide")
	player_node.play_sound_effect(slide_audio_stream_player, 0.0, 0.85, 0.9)
	player_node.set_slide_detector_active(true)
	player_node.stamina_system.consume(player_node.SLIDE_STAMINA_COST)

func process_state(delta: float):
	_offset = clampf(_offset + delta, 0.0, slide_curve.max_domain)
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_directional_slide_move(player_node.SLIDE_MAX_SPEED * slide_curve.sample_baked(_offset))
	if player_node.is_on_wall() and _offset < 0.4 * slide_curve.max_domain:
		return player_node.fsm.state_nodes.bump_into_wall
	if not player_node.is_on_floor():
		return player_node.fsm.state_nodes.fall
	match _state:
		State.crouch_to_slide:
			if player_node.is_animation_finished():
				_state = State.slide
				player_node.play_animation("slide")
		State.slide:
			if player_node.is_stopped():
				_state = State.slide_to_crouch
				player_node.play_animation("slide_to_crouch")
		State.slide_to_crouch:
			if player_node.is_animation_finished():
				return player_node.fsm.state_nodes.crouch

func finish_state():
	if player_node.fsm.next_state_node != player_node.fsm.state_nodes.crouch and player_node.fsm.next_state_node != player_node.fsm.state_nodes.bump_into_wall:
		player_node.uncrouch()
	player_node.set_slide_detector_active(false)

func _on_slide_detector_area_entered(area: Area2D):
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.SLIDE_DAMAGE, RkLifePointsSystem.DmgType.slide)
