class_name RkPlayerCollision

var player_node: RkPlayer

# @impure
func _init(_player_node: RkPlayer) -> void:
	player_node = _player_node

# @impure
func set_roll_hitbox_active(active: bool) -> void:
	player_node.roll_hitbox.monitoring = active
	player_node.roll_hitbox.monitorable = active

# @impure
func set_slide_hitbox_active(active: bool) -> void:
	player_node.slide_hitbox.monitoring = active
	player_node.slide_hitbox.monitorable = active

# @impure
func set_attack_hitbox_active(active: bool) -> void:
	player_node.attack_hitbox.monitoring = active
	player_node.attack_hitbox.monitorable = active

# @impure
func set_crouch_attack_hitbox_active(active: bool) -> void:
	player_node.crouch_attack_hitbox.monitoring = active
	player_node.crouch_attack_hitbox.monitorable = active

# @impure
func set_wall_hang_raycast_active(active: bool) -> void:
	player_node.wall_hang_down_raycast.enabled = active
	player_node.wall_hang_down_raycast.force_raycast_update()

# @impure
func set_wall_slide_raycast_active(active: bool) -> void:
	player_node.wall_slide_down_raycast.enabled = active
	player_node.wall_slide_down_raycast.force_raycast_update()
	player_node.wall_slide_top_side_raycast.enabled = active
	player_node.wall_slide_top_side_raycast.force_raycast_update()
	player_node.wall_slide_down_side_raycast.enabled = active
	player_node.wall_slide_down_side_raycast.force_raycast_update()

# @impure
func set_one_way_shapecast_active(active: bool) -> void:
	player_node.one_way_shapecast.enabled = active
	player_node.one_way_shapecast.force_shapecast_update()

# @impure
func set_uncrouch_shapecast_active(active: bool) -> void:
	player_node.uncrouch_shapecast.enabled = active
	player_node.uncrouch_shapecast.force_shapecast_update()

# @impure
func set_wall_climb_shapecast_active(active: bool) -> void:
	player_node.wall_climb_stand_shapecast.enabled = active
	player_node.wall_climb_stand_shapecast.force_shapecast_update()
	player_node.wall_climb_crouch_shapecast.enabled = active
	player_node.wall_climb_crouch_shapecast.force_shapecast_update()
