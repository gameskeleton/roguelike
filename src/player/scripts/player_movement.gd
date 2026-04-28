class_name RkPlayerMovement

var player_node: RkPlayer

# @impure
func _init(_player_node: RkPlayer) -> void:
	player_node = _player_node

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
	if player_node.velocity.x == 0.0 or player_node.has_same_direction(player_node.velocity.x, player_node.input.velocity.x):
		player_node.velocity.x = move_toward(player_node.velocity.x, max_speed * signf(player_node.direction), acceleration * delta)
	else:
		player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)

# @impure
func apply_airborne_move_input(delta: float, max_speed: float, acceleration: float, deceleration: float) -> void:
	if not player_node.input.has_horizontal_input():
		player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)
	elif player_node.velocity.x == 0.0:
		player_node.velocity.x = move_toward(player_node.velocity.x, max_speed * signf(player_node.input.velocity.x), acceleration * delta)
	elif player_node.has_same_direction(player_node.velocity.x, player_node.input.velocity.x):
		player_node.velocity.x = move_toward(player_node.velocity.x, max_speed * signf(player_node.input.velocity.x), acceleration * delta)
	else:
		player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)

# @impure
func apply_floor_deceleration(delta: float, deceleration: float) -> void:
	player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)

# @impure
func apply_airborne_deceleration(delta: float, deceleration: float) -> void:
	player_node.velocity.x = move_toward(player_node.velocity.x, 0.0, deceleration * delta)
