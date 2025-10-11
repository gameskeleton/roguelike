extends RkStateMachineState

@export var offset_curve: Curve

@export_group(&"Nodes")
@export var roll_audio_stream_player: AudioStreamPlayer

var _sprite_initial_offset := Vector2()
var _animation_initial_speed_scale := 1.0

func start_state():
	_sprite_initial_offset = player_node.sprite.offset
	_animation_initial_speed_scale = player_node.animation_player.speed_scale
	if not player_node.crouched:
		player_node.crouch()
	player_node.dash(player_node.ROLL_STRENGTH)
	player_node.play_animation(&"roll")
	player_node.play_sound_effect(roll_audio_stream_player, 0.0, 0.85, 0.9)
	player_node.set_roll_hitbox_active(true)
	player_node.set_one_way_shapecast_active(true)
	player_node.set_uncrouch_shapecast_active(true)
	player_node.stamina_system.consume(player_node.ROLL_STAMINA_COST)
	player_node.animation_player.speed_scale = 2.1
	player_node.life_points_system.invincible += 1

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.ROLL_DECELERATION)
	player_node.sprite.offset.x = _sprite_initial_offset.x + player_node.direction * offset_curve.sample_baked(player_node.get_animation_played_ratio())
	if player_node.is_on_wall() and player_node.get_animation_played_ratio() < 0.5:
		return player_node.fsm.state_nodes.bump_into_wall
	if player_node.get_animation_played_ratio() > 0.8:
		if player_node.input_jump.is_pressed() and player_node.input_down.is_down() and player_node.is_on_floor_one_way():
			player_node.input_jump.consume()
			player_node.input_down.consume()
			player_node.handle_drop_through_one_way()
			return player_node.fsm.state_nodes.fall
		if player_node.input_jump.is_pressed() and player_node.is_on_floor() and player_node.is_able_to_jump() and player_node.is_able_to_uncrouch():
			player_node.input_jump.consume()
			return player_node.fsm.state_nodes.jump
	if player_node.is_animation_finished():
		if not player_node.input_down.is_down() and player_node.is_able_to_uncrouch():
			player_node.input_down.consume()
			return player_node.fsm.state_nodes.stand
		return player_node.fsm.state_nodes.crouch

func finish_state():
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.crouch, player_node.fsm.state_nodes.bump_into_wall]):
		player_node.uncrouch()
	player_node.sprite.offset = _sprite_initial_offset
	player_node.animation_player.speed_scale = _animation_initial_speed_scale
	player_node.life_points_system.invincible -= 1
	player_node.stop_sound_effect(roll_audio_stream_player)
	player_node.set_roll_hitbox_active(false)
	player_node.set_one_way_shapecast_active(false)
	player_node.set_uncrouch_shapecast_active(false)

func _on_roll_hitbox_area_entered(area: Area2D):
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.ROLL_DAMAGE, RkLifePointsSystem.DmgType.roll)
