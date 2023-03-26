extends RkStateMachineState

var _combo := false
var _attack_combo := 0
var _hitbox_enabled := false
var _animation_initial_speed_scale := 1.0

func start_state():
	_combo = false
	_attack_combo = 0
	_hitbox_enabled = false
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.animation_player.speed_scale = 1.6
	player_node.play_animation("attack_01")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.ATTACK_DECELERATION)
	if player_node.input_attack and player_node.get_animation_played_ratio() >= 0.8:
		_combo = true
	if player_node.is_animation_finished():
		if _combo:
			_combo = false
			_attack_combo += 1
			player_node.animation_player.speed_scale = min(3.0, player_node.animation_player.speed_scale + 0.2)
			player_node.play_animation("attack_01" if _attack_combo % 2 == 0 else "attack_02")
		else:
			player_node.animation_player.stop()
			return player_node.fsm.state_nodes.stand
	# collision detection
	if _hitbox_enabled and player_node.attack_detector.has_overlapping_bodies():
		for body in player_node.attack_detector.get_overlapping_bodies():
			if body is RkDecor:
				body._destroyed(player_node)

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
