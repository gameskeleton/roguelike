extends RkStateMachineState

var _combo := false
var _air_control := false
var _attack_combo := 0
var _hitbox_enabled := false
var _animation_initial_speed_scale := 1.0

func start_state():
	_combo = false
	_air_control = not player_node.is_on_floor()
	_attack_combo = 0
	_hitbox_enabled = false
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.animation_player.speed_scale = 1.6
	player_node.play_animation("attack_01")
	player_node.stamina.consume(player_node.ATTACK_STAMINA_COST)

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
	if player_node.input_pressed(player_node.input_attack) and player_node.get_animation_played_ratio() >= 0.8:
		_combo = true
	if player_node.is_animation_finished():
		if _combo and player_node.stamina.try_consume(player_node.ATTACK_STAMINA_COST):
			_combo = false
			_attack_combo += 1
			player_node.animation_player.speed_scale = min(3.0, player_node.animation_player.speed_scale + 0.2)
			player_node.play_animation("attack_01" if _attack_combo % 2 == 0 else "attack_02")
		else:
			player_node.animation_player.stop()
			return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.set_attack_detector_active(false)

# @impure
func _enable_hitbox():
	player_node.set_attack_detector_active(true)
	_hitbox_enabled = true

# @impure
func _disable_hitbox():
	_hitbox_enabled = false
	player_node.set_attack_detector_active(false)

# @signal
# @impure
func _on_attack_detector_area_entered(area: Area2D):
	var parent_node := area.get_parent()
	if parent_node:
		var life_points_node := RkLifePoints.find_life_points_in_node(parent_node)
		if life_points_node is RkLifePoints:
			life_points_node.call_deferred("take_damage", 1.4 + 0.8 * player_node.level.level, RkLifePoints.DmgType.physical)
