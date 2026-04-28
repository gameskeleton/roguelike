extends RkStateMachineState

const SOUND_POSITION_01 := 0.015
const SOUND_POSITION_02 := 0.005

var _combo := false
var _air_control := false
var _attack_combo := 0
var _animation_initial_speed_scale := 1.0

@export_group(&"Nodes")
@export var attack_audio_stream_player: AudioStreamPlayer

func start_state() -> RkStateMachineState:
	_combo = false
	_air_control = not player_node.is_on_floor()
	_attack_combo = 0
	_animation_initial_speed_scale = player_node.animation.speed_scale
	player_node.audio.play_sound_effect(attack_audio_stream_player, SOUND_POSITION_01)
	player_node.animation.speed_scale = 1.6
	player_node.animation.play_animation(&"attack_01")
	player_node.stamina_system.consume(player_node.ATTACK_STAMINA_COST)
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	# air control
	if _air_control:
		if player_node.is_on_floor():
			_air_control = false
		player_node.movement.apply_airborne_move_input(delta, player_node.ATTACK_MAX_SPEED, player_node.ATTACK_ACCELERATION, player_node.ATTACK_DECELERATION)
	else:
		player_node.movement.apply_floor_deceleration(delta, player_node.ATTACK_DECELERATION)
	# attack combo
	if player_node.input.attack.is_down() and player_node.animation.get_animation_played_ratio() >= 0.8:
		_combo = true
		player_node.input.attack.consume()
	if player_node.animation.is_animation_finished():
		if _combo and player_node.stamina_system.try_consume(player_node.ATTACK_STAMINA_COST):
			_combo = false
			_attack_combo += 1
			player_node.animation.speed_scale = minf(3.0, player_node.animation.speed_scale + 0.2)
			player_node.animation.play_animation(&"attack_01" if _attack_combo % 2 == 0 else &"attack_02")
			player_node.audio.play_sound_effect(attack_audio_stream_player, SOUND_POSITION_02)
		else:
			player_node.animation_player.stop()
			return player_node.fsm.state_nodes.fall if not player_node.is_on_floor() else player_node.fsm.state_nodes.stand
	return null

func finish_state() -> void:
	player_node.animation.speed_scale = _animation_initial_speed_scale
	player_node.collision.set_attack_hitbox_active(false)

# @anim
# @impure
func _enable_hitbox() -> void:
	player_node.collision.set_attack_hitbox_active(true)

# @anim
# @impure
func _disable_hitbox() -> void:
	player_node.collision.set_attack_hitbox_active(false)

# @signal
# @impure
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.ATTACK_DAMAGE, RkLifePointsSystem.DmgType.physical)
