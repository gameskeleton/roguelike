extends RkStateMachineState

var _animation_initial_speed_scale := 1.0

@export_group(&"Nodes")
@export var crouch_attack_audio_stream_player: AudioStreamPlayer

func start_state() -> RkStateMachineState:
	_animation_initial_speed_scale = player_node.animation.speed_scale
	player_node.stamina_system.consume(player_node.CROUCH_ATTACK_STAMINA_COST)
	player_node.animation.speed_scale = 1.6
	player_node.animation.play_animation(&"crouch_attack")
	player_node.audio.play_sound_effect(crouch_attack_audio_stream_player)
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.CROUCH_DECELERATION)
	if player_node.animation.is_animation_finished():
		return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	player_node.animation.speed_scale = _animation_initial_speed_scale

# @impure
func _enable_hitbox() -> void:
	player_node.collision.set_crouch_attack_hitbox_active(true)

# @impure
func _disable_hitbox() -> void:
	player_node.collision.set_crouch_attack_hitbox_active(false)

# @signal
# @impure
func _on_crouch_attack_hitbox_area_entered(area: Area2D) -> void:
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.CROUCH_ATTACK_DAMAGE, RkLifePointsSystem.DmgType.physical)
