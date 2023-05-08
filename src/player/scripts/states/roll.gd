extends RkStateMachineState

@export var offset_curve: Curve

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _sprite_initial_offset := Vector2()
var _animation_initial_speed_scale := 1.0

func start_state():
	_sprite_initial_offset = player_node.sprite.offset
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	if not player_node.crouched:
		player_node.crouch()
	player_node.roll(player_node.direction * player_node.ROLL_STRENGTH)
	player_node.play_animation("roll")
	player_node.play_sound_effect(audio_stream_player, 0.0, 0.85, 0.9)
	player_node.set_roll_detector_active(true)
	player_node.set_crouch_detector_active(true)
	player_node.stamina_system.consume(player_node.ROLL_STAMINA_COST)
	player_node.animation_player.speed_scale = 2.1
	player_node.life_points_system.invincible += 1

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.ROLL_DECELERATION)
	player_node.sprite.offset.x = _sprite_initial_offset.x + player_node.direction * offset_curve.sample_baked(player_node.get_animation_played_ratio())
	if player_node.is_on_wall() and player_node.get_animation_played_ratio() < 0.5:
		return player_node.fsm.state_nodes.bump_into_wall
	if player_node.input_just_pressed(player_node.input_jump) and player_node.is_on_floor() and player_node.is_able_to_jump() and player_node.get_animation_played_ratio() > 0.8:
		return player_node.fsm.state_nodes.jump
	if player_node.is_animation_finished():
		if player_node.is_able_to_uncrouch():
			return player_node.fsm.state_nodes.stand
		return player_node.fsm.state_nodes.crouch

func finish_state():
	if player_node.fsm.next_state_node != player_node.fsm.state_nodes.crouch and player_node.fsm.next_state_node != player_node.fsm.state_nodes.bump_into_wall:
		player_node.uncrouch()
	player_node.sprite.offset = _sprite_initial_offset
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.life_points_system.invincible -= 1
	player_node.stop_sound_effect(audio_stream_player)
	player_node.set_roll_detector_active(false)
	player_node.set_crouch_detector_active(false)

func _on_roll_detector_area_entered(area: Area2D):
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.call_deferred("attack", target_node, player_node.ROLL_DAMAGE, RkLifePointsSystem.DmgType.roll)
