extends RkStateMachineState

@export var offset_curve: Curve

var _sprite_initial_offset := Vector2()
var _animation_initial_speed_scale := 1.0

func start_state():
	_sprite_initial_offset = player_node.sprite.offset
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	player_node.handle_roll(player_node.direction * player_node.ROLL_STRENGTH)
	player_node.play_animation("roll")
	player_node.set_roll_detector_active(true)
	player_node.animation_player.speed_scale = 1.8

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.ROLL_DECELERATION)
	player_node.sprite.offset.x = _sprite_initial_offset.x + player_node.direction * offset_curve.sample_baked(player_node.get_animation_played_ratio())
	if player_node.is_on_wall() and player_node.get_animation_played_ratio() < 0.5:
		return player_node.fsm.state_nodes.bump_into_wall
	if player_node.input_jump_once and player_node.is_on_floor() and player_node.is_able_to_jump() and player_node.get_animation_played_ratio() > 0.8:
		return player_node.fsm.state_nodes.jump
	if player_node.is_animation_finished():
		return player_node.fsm.state_nodes.stand
	# cosmetics
	if player_node.roll_detector.has_overlapping_bodies():
		for body in player_node.roll_detector.get_overlapping_bodies():
			if body is RkDecor:
				body._roll(player_node)

func finish_state():
	player_node.sprite.offset = _sprite_initial_offset
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.set_roll_detector_active(false)
