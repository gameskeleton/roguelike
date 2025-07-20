extends RkStateMachineState

const SOUND_POSITION_01 := 0.015
const SOUND_POSITION_02 := 0.005

var _combo := false
var _air_control := false
var _attack_combo := 0
var _animation_initial_speed_scale := 1.0

@export_group("Nodes")
@export var attack_audio_stream_player: AudioStreamPlayer

func start_state():
	_combo = false
	_air_control = not player_node.is_on_floor()
	_attack_combo = 0
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.stamina_system.consume(player_node.ATTACK_STAMINA_COST)
	player_node.animation_player.speed_scale = 1.6
	player_node.play_animation("attack_01")
	player_node.play_sound_effect(attack_audio_stream_player, SOUND_POSITION_01)

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	# air control
	if _air_control:
		if player_node.is_on_floor():
			_air_control = false
		player_node.handle_airborne_move(delta, player_node.ATTACK_MAX_SPEED, player_node.ATTACK_ACCELERATION, player_node.ATTACK_DECELERATION)
	else:
		player_node.handle_deceleration_move(delta, player_node.ATTACK_DECELERATION)
	# attack combo
	if player_node.input_attack.is_down() and player_node.get_animation_played_ratio() >= 0.8:
		_combo = true
		player_node.input_attack.consume()
	if player_node.is_animation_finished():
		if _combo and player_node.stamina_system.try_consume(player_node.ATTACK_STAMINA_COST):
			_combo = false
			_attack_combo += 1
			player_node.animation_player.speed_scale = minf(3.0, player_node.animation_player.speed_scale + 0.2)
			player_node.play_animation("attack_01" if _attack_combo % 2 == 0 else "attack_02")
			player_node.play_sound_effect(attack_audio_stream_player, SOUND_POSITION_02)
		else:
			player_node.animation_player.stop()
			return player_node.fsm.state_nodes.fall if not player_node.is_on_floor() else player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.set_attack_hitbox_active(false)

# @impure
func _enable_hitbox():
	player_node.set_attack_hitbox_active(true)

# @impure
func _disable_hitbox():
	player_node.set_attack_hitbox_active(false)

# @signal
# @impure
func _on_attack_hitbox_area_entered(area: Area2D):
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.ATTACK_DAMAGE, RkLifePointsSystem.DmgType.physical)
