extends RkStateMachineState

var _animation_initial_speed_scale := 1.0

@export_group("Nodes")
@export var crouch_attack_audio_stream_player: AudioStreamPlayer

func start_state():
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.stamina_system.consume(player_node.CROUCH_ATTACK_STAMINA_COST)
	player_node.animation_player.speed_scale = 1.6
	player_node.play_animation("crouch_attack")
	player_node.play_sound_effect(crouch_attack_audio_stream_player)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.CROUCH_DECELERATION)
	if player_node.is_animation_finished():
		return player_node.fsm.state_nodes.crouch

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale

# @impure
func _enable_hitbox():
	player_node.set_crouch_attack_detector_active(true)

# @impure
func _disable_hitbox():
	player_node.set_crouch_attack_detector_active(false)

# @signal
# @impure
func _on_crouch_attack_detector_area_entered(area: Area2D):
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.CROUCH_ATTACK_DAMAGE, RkLifePointsSystem.DmgType.physical)
