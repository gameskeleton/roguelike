class_name RkPlayerMovement

var player_node: RkPlayer

# @impure
func _init(_player_node: RkPlayer) -> void:
	player_node = _player_node

###
# Actions
###

# @impure
func jump(strength: float) -> void:
	player_node.velocity.y = strength

# @impure
func dash(slide_velocity: float) -> void:
	player_node.velocity.x = slide_velocity * player_node.direction

# @impure
func crouch() -> void:
	assert(not player_node.crouched)
	player_node.crouched = true
	player_node.collider_stand.disabled = true
	player_node.collider_crouch.disabled = false

# @impure
func uncrouch() -> void:
	assert(player_node.crouched)
	player_node.crouched = false
	player_node.collider_stand.disabled = false
	player_node.collider_crouch.disabled = true

# @impure
func drop_through_one_way() -> void:
	player_node.collision_mask &= ~player_node.one_way_collision_layer
	await player_node.get_tree().create_timer(0.2).timeout
	player_node.collision_mask |= +player_node.one_way_collision_layer

# @impure
func reset_safe_margin_after_teleport() -> void:
	player_node.velocity.y -= player_node.safe_margin

###
# Appliers
###

# @impure
func apply_gravity(delta: float, max_speed: float = player_node.GRAVITY_MAX_SPEED, acceleration: float = player_node.GRAVITY_ACCELERATION) -> void:
	player_node.velocity.y = move_toward(player_node.velocity.y, max_speed, delta * acceleration)

# @impure
func apply_direction() -> void:
	var input_direction := int(signf(player_node.input.velocity.x))
	if input_direction != 0.0:
		player_node.set_direction(input_direction)

# @impure
func apply_floor_move_input(delta: float, max_speed: float, acceleration: float, deceleration: float) -> void:
	var target := max_speed * signf(player_node.direction)
	var accelerate := player_node.input.has_horizontal_input()
	player_node.velocity.x = move_toward(player_node.velocity.x, target if accelerate else 0.0, (acceleration if accelerate else deceleration) * delta)

# @impure
func apply_airborne_move_input(delta: float, max_speed: float, acceleration: float, deceleration: float) -> void:
	var target := max_speed * signf(player_node.input.velocity.x)
	var accelerate := player_node.input.has_horizontal_input()
	player_node.velocity.x = move_toward(player_node.velocity.x, target if accelerate else 0.0, (acceleration if accelerate else deceleration) * delta)

# @impure
func apply_floor_deceleration(delta: float, deceleration: float) -> void:
	player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)

# @impure
func apply_airborne_deceleration(delta: float, deceleration: float) -> void:
	player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)

###
# Checks
###

# is_stopped returns true if the player is nearly stopped.
# @pure
func is_stopped() -> bool:
	return player_node.get_real_velocity().length_squared() < 1.0

# is_on_floor_one_way returns true if the player is on the floor and standing on a one way collider.
# @pure
func is_on_floor_one_way() -> bool:
	assert(player_node.one_way_shapecast.enabled, "is_on_floor_one_way can only be called after calling set_one_way_shapecast_active(true)")
	return player_node.is_on_floor() and player_node.one_way_shapecast.is_colliding()

# is_moving_with_input returns true if player velocity aligns with input direction.
# @pure
func is_moving_with_input() -> bool:
	return player_node.velocity.x != 0.0 and player_node.input.velocity.x != 0.0 and signf(player_node.velocity.x) == signf(player_node.input.velocity.x)

# is_moving_against_input returns true if player velocity opposes input direction.
# @pure
func is_moving_against_input() -> bool:
	return player_node.velocity.x != 0.0 and player_node.input.velocity.x != 0.0 and signf(player_node.velocity.x) != signf(player_node.input.velocity.x)

# is_facing_with_input returns true if player is facing the same direction as input.
# @pure
func is_facing_with_input() -> bool:
	return player_node.direction != 0.0 and player_node.input.velocity.x != 0.0 and signf(player_node.direction) == signf(player_node.input.velocity.x)

# is_facing_against_input returns true if player is facing opposite to input direction.
# @pure
func is_facing_against_input() -> bool:
	return player_node.direction != 0.0 and player_node.input.velocity.x != 0.0 and signf(player_node.direction) != signf(player_node.input.velocity.x)

# has_corner_tile_at_hand returns true if there is a corner tile at the wall hang hand's position.
# @pure
func has_corner_tile_at_hand() -> bool:
	if not player_node.level_manager_node.level_node:
		push_warning("has_corner_tile_at_hand should not be called outside of a level")
		return false
	return player_node.level_manager_node.level_node.has_corner_tile(player_node.hand_marker.global_position)

# get_corner_tile_pos_at_hand returns the top-center position of the corner tile at the wall hang hand's position.
# @pure
func get_corner_tile_pos_at_hand() -> Vector2:
	assert(player_node.level_manager_node.level_node, "get_corner_tile_pos_at_hand cannot be called outside of a level")
	assert(has_corner_tile_at_hand(), "get_corner_tile_pos_at_hand called without checking if has_corner_tile_at_hand")
	return player_node.level_manager_node.level_node.get_corner_tile_pos(player_node.hand_marker.global_position)
