extends RkStateMachineState

func start_state():
	var damage_direction := 1.0
	if player_node.life_points.last_damage_source is Node2D:
		damage_direction = 1.0 if player_node.life_points.last_damage_source.global_position.x < player_node.global_position.x else -1.0
	player_node.velocity = Vector2(damage_direction * player_node.HIT_IMPULSE.x, player_node.HIT_IMPULSE.y)
	player_node.life_points.invincible += 1
	player_node.play_animation("hit")

func process_state(delta: float):
	player_node.handle_gravity(delta, player_node.GRAVITY_MAX_SPEED, player_node.GRAVITY_ACCELERATION)
	player_node.handle_deceleration_move(delta, player_node.RUN_DECELERATION)
	if player_node.is_animation_finished():
		return player_node.fsm.state_nodes.stand

func finish_state():
	player_node.life_points.invincible -= 1
