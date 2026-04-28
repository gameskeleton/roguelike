extends RkStateMachineState

@export var offset_curve: Curve

@export_group(&"Nodes")
@export var roll_audio_stream_player: AudioStreamPlayer

var _sprite_initial_offset := Vector2()
var _animation_initial_speed_scale := 1.0

func start_state() -> RkStateMachineState:
	_sprite_initial_offset = player_node.sprite.offset
	_animation_initial_speed_scale = player_node.animation.speed_scale
	if not player_node.crouched:
		player_node.movement.crouch()
	player_node.audio.play_sound_effect(roll_audio_stream_player, 0.0, 0.85, 0.9)
	player_node.movement.dash(player_node.ROLL_STRENGTH)
	player_node.animation.speed_scale = 2.1
	player_node.animation.play_animation(&"roll")
	player_node.collision.set_roll_hitbox_active(true)
	player_node.collision.set_one_way_shapecast_active(true)
	player_node.collision.set_uncrouch_shapecast_active(true)
	player_node.stamina_system.consume(player_node.ROLL_STAMINA_COST)
	player_node.life_points_system.invincible += 1
	return null

func process_state(delta: float) -> RkStateMachineState:
	player_node.movement.apply_gravity(delta)
	player_node.movement.apply_floor_deceleration(delta, player_node.ROLL_DECELERATION)
	player_node.sprite.offset.x = _sprite_initial_offset.x + player_node.direction * offset_curve.sample_baked(player_node.animation.get_animation_played_ratio())
	if player_node.is_on_wall() and player_node.animation.get_animation_played_ratio() < 0.5:
		return player_node.fsm.state_nodes.bump_into_wall
	if player_node.animation.get_animation_played_ratio() > 0.8:
		if player_node.input.jump.is_pressed() and player_node.input.down.is_down() and player_node.is_on_floor_one_way():
			player_node.input.jump.consume()
			player_node.input.down.consume()
			player_node.movement.drop_through_one_way()
			return player_node.fsm.state_nodes.fall
		if player_node.input.jump.is_pressed() and player_node.is_on_floor() and player_node.is_able_to_jump() and player_node.is_able_to_uncrouch():
			player_node.input.jump.consume()
			return player_node.fsm.state_nodes.jump
	if player_node.animation.is_animation_finished():
		if not player_node.input.down.is_down() and player_node.is_able_to_uncrouch():
			player_node.input.down.consume()
			return player_node.fsm.state_nodes.stand
		return player_node.fsm.state_nodes.crouch
	return null

func finish_state() -> void:
	if not player_node.fsm.is_next_state_node([player_node.fsm.state_nodes.hit, player_node.fsm.state_nodes.death, player_node.fsm.state_nodes.crouch, player_node.fsm.state_nodes.bump_into_wall]):
		player_node.movement.uncrouch()
	player_node.sprite.offset = _sprite_initial_offset
	player_node.animation.speed_scale = _animation_initial_speed_scale
	player_node.life_points_system.invincible -= 1
	player_node.audio.stop_sound_effect(roll_audio_stream_player)
	player_node.collision.set_roll_hitbox_active(false)
	player_node.collision.set_one_way_shapecast_active(false)
	player_node.collision.set_uncrouch_shapecast_active(false)

func _on_roll_hitbox_area_entered(area: Area2D) -> void:
	var target_node := RkLifePointsSystem.find_system_node(area.get_parent())
	if target_node is RkLifePointsSystem:
		player_node.attack_system.attack.call_deferred(target_node, player_node.ROLL_DAMAGE, RkLifePointsSystem.DmgType.roll)
