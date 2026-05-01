class_name RkPlayer extends CharacterBody2D

const SIZE := Vector2(14.0, 34.0)
const CROUCH_SIZE := Vector2(14.0, 24.0)
const ONE_WAY_MARGIN := 2
const CEILING_KNOCKDOWN := 0.0

const COYOTE_TIME := 0.1
const JUMP_STRENGTH := -260.0
const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0
const GRAVITY_FAST_ACCELERATION := 1200.0

const HIT_IMPULSE := Vector2(140.0, 0.0)

const WALK_MAX_SPEED := 126.0
const WALK_ACCELERATION := 410.0
const WALK_DECELERATION := 480.0
const WALK_DECELERATION_BRAKE := 1.6

const ROLL_DAMAGE := 1.0
const ROLL_STRENGTH := 220.0
const ROLL_STAMINA_COST := 2.0
const ROLL_DECELERATION := 290.0
const ROLL_BUMP_STRENGTH := -70.0

const DEATH_DECELERATION := 290.0

const SLIDE_DAMAGE := 1.0
const SLIDE_MAX_SPEED := 160.0
const SLIDE_STAMINA_COST := 2.0

const ATTACK_DAMAGE := 1.0
const ATTACK_MAX_SPEED := 120.0
const ATTACK_STAMINA_COST := 2.0
const ATTACK_ACCELERATION := 310.0
const ATTACK_DECELERATION := 510.0

const CROUCH_MAX_SPEED := 66.0
const CROUCH_LOCK_DELAY := 0.1
const CROUCH_ACCELERATION := 280.0
const CROUCH_DECELERATION := 460.0
const CROUCH_DECELERATION_BRAKE := 1.6

const CROUCH_ATTACK_DAMAGE := 0.8
const CROUCH_ATTACK_STAMINA_COST := 2.0

const WALL_HANG_DROP_TIMEOUT := 0.3
const WALL_HANG_JUMP_STRENGTH := -200.0
const WALL_HANG_JUMP_EXPULSE_STRENGTH := -100.0

const WALL_SLIDE_JUMP_STRENGTH := -240.0
const WALL_SLIDE_GRAVITY_MAX_SPEED := GRAVITY_MAX_SPEED * 0.2
const WALL_SLIDE_GRAVITY_ACCELERATION := GRAVITY_ACCELERATION * 0.1
const WALL_SLIDE_JUMP_EXPULSE_STRENGTH := -160.0
const WALL_SLIDE_ENTER_MAX_VERTICAL_VELOCITY := 20.0

###
# References
###

@export_group(&"Systems")
@export var gold_system: RkGoldSystem
@export var level_system: RkLevelSystem
@export var attack_system: RkAttackSystem
@export var stamina_system: RkStaminaSystem
@export var life_points_system: RkLifePointsSystem

@export_group(&"References")
@export var sprite: Sprite2D
@export var level_node: RkLevel
@export var hand_marker: Marker2D
@export var animation_player: AnimationPlayer

@export var collider_stand: CollisionShape2D
@export var collider_crouch: CollisionShape2D

@export var roll_hitbox: Area2D
@export var slide_hitbox: Area2D
@export var attack_hitbox: Area2D
@export var crouch_attack_hitbox: Area2D

@export var wall_hang_down_raycast: RayCast2D
@export var wall_slide_down_raycast: RayCast2D
@export var wall_slide_top_side_raycast: RayCast2D
@export var wall_slide_down_side_raycast: RayCast2D

@export var one_way_shapecast: ShapeCast2D
@export var uncrouch_shapecast: ShapeCast2D
@export var wall_climb_stand_shapecast: ShapeCast2D
@export var wall_climb_crouch_shapecast: ShapeCast2D

@export var coin_picked_up_audio_stream_player: AudioStreamPlayer
@export var experience_picked_up_audio_stream_player: AudioStreamPlayer

###
# Initial values
###

@export_group(&"Initial values")
@export var direction := 1.0
@export var base_force := 1.0
@export var base_stamina := 10.0
@export var base_life_points := 10.0
@export var additional_force_per_level := Curve.new()
@export var additional_stamina_per_level := Curve.new()
@export var additional_life_points_per_level := Curve.new()

###
# Signals
###

signal death()
signal stamina_ratio_changed(stamina_ratio: float)
signal life_points_ratio_changed(life_points_ratio: float)

###
# Variables
###

var dead := false
var crouched := false
var disable_wall_hang_timeout := 0.0
@export var root_motion := Vector2.ZERO
@export_flags_2d_physics var one_way_collision_layer := 0

###
# Components
###

@onready var fsm := RkStateMachine.new(self, $StateMachine, $StateMachine/stand as RkStateMachineState)
@onready var audio := RkPlayerAudio.new(self)
@onready var input := RkPlayerInput.new(self)
@onready var movement := RkPlayerMovement.new(self)
@onready var animation := RkPlayerAnimation.new(self)
@onready var collision := RkPlayerCollision.new(self)

# @impure
func _ready() -> void:
	# references
	assert(sprite != null, "sprite not set")
	assert(level_node != null, "level_node not set")
	assert(hand_marker != null, "hand_marker not set")
	assert(animation_player != null, "animation_player not set")
	assert(collider_stand != null, "collider_stand not set")
	assert(collider_crouch != null, "collider_crouch not set")
	assert(roll_hitbox != null, "roll_hitbox not set")
	assert(slide_hitbox != null, "slide_hitbox not set")
	assert(attack_hitbox != null, "attack_hitbox not set")
	assert(crouch_attack_hitbox != null, "crouch_attack_hitbox not set")
	assert(wall_hang_down_raycast != null, "wall_hang_down_raycast not set")
	assert(wall_slide_down_raycast != null, "wall_slide_down_raycast not set")
	assert(wall_slide_top_side_raycast != null, "wall_slide_top_side_raycast not set")
	assert(wall_slide_down_side_raycast != null, "wall_slide_down_side_raycast not set")
	assert(one_way_shapecast != null, "one_way_shapecast not set")
	assert(uncrouch_shapecast != null, "uncrouch_shapecast not set")
	assert(wall_climb_stand_shapecast != null, "wall_climb_stand_shapecast not set")
	assert(wall_climb_crouch_shapecast != null, "wall_climb_crouch_shapecast not set")
	assert(coin_picked_up_audio_stream_player != null, "coin_picked_up_audio_stream_player not set")
	assert(experience_picked_up_audio_stream_player != null, "experience_picked_up_audio_stream_player not set")
	assert(gold_system != null, "gold_system not set")
	assert(level_system != null, "level_system not set")
	assert(attack_system != null, "attack_system not set")
	assert(stamina_system != null, "stamina_system not set")
	assert(life_points_system != null, "life_points_system not set")
	# set default values.
	set_direction(direction)
	_on_level_level_up(level_system.level.value)
	# replenish system values.
	stamina_system.stamina.replenish()
	life_points_system.life_points.replenish()
	# make sure the collision's are safe.
	movement.reset_safe_margin_after_teleport()

# @impure
func _physics_process(delta: float) -> void:
	process(delta)

# @impure
func process(delta: float) -> void:
	input.process(delta)
	process_velocity(delta)
	process_timeouts(delta)
	fsm.process_state_machine(delta)

# process_velocity updates player position after applying velocity.
# @impure
func process_velocity(_delta: float) -> void:
	move_and_slide()

# process_timeouts decreases timeouts.
# @impure
func process_timeouts(delta: float) -> void:
	disable_wall_hang_timeout = maxf(disable_wall_hang_timeout - delta, 0.0)

###
# Player
###

# die makes the player collapse and emit the death signal.
# @impure
func die() -> void:
	dead = true
	death.emit()
	fsm.set_state_node(fsm.state_nodes.death)

# hit makes the player hurt and invincible for a little while.
# @impure
func hit() -> void:
	fsm.set_state_node(fsm.state_nodes.hit)

# set_direction changes the player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: float) -> void:
	direction = new_direction
	sprite.flip_h = new_direction < 0.0
	sprite.offset.x = -9.0 if new_direction < 0.0 else 1.0
	hand_marker.position.x = absf(hand_marker.position.x) * new_direction
	roll_hitbox.scale.x = new_direction
	slide_hitbox.scale.x = new_direction
	attack_hitbox.scale.x = new_direction
	crouch_attack_hitbox.scale.x = new_direction
	wall_climb_stand_shapecast.position.x = absf(wall_climb_stand_shapecast.position.x) * new_direction
	wall_climb_stand_shapecast.force_shapecast_update()
	wall_climb_crouch_shapecast.position.x = absf(wall_climb_crouch_shapecast.position.x) * new_direction
	wall_climb_crouch_shapecast.force_shapecast_update()
	wall_slide_down_raycast.target_position.x = absf(wall_slide_down_raycast.target_position.x) * new_direction
	wall_slide_down_raycast.force_raycast_update()
	wall_slide_top_side_raycast.target_position.x = absf(wall_slide_top_side_raycast.target_position.x) * new_direction
	wall_slide_top_side_raycast.force_raycast_update()
	wall_slide_down_side_raycast.target_position.x = absf(wall_slide_down_side_raycast.target_position.x) * new_direction
	wall_slide_down_side_raycast.force_raycast_update()

###
# Capabilities
###

# is_able_to_jump returns true if the player is able to jump.
# @pure
func is_able_to_jump() -> bool:
	return true

# is_able_to_roll returns true if the player is able to roll.
# @pure
func is_able_to_roll() -> bool:
	return stamina_system.has_enough(ROLL_STAMINA_COST)

# is_able_to_slide returns true if the player is able to slide.
# @pure
func is_able_to_slide() -> bool:
	return stamina_system.has_enough(SLIDE_STAMINA_COST)

# is_able_to_crouch returns true if the player is able to crouch.
# @pure
func is_able_to_crouch() -> bool:
	return true

# is_able_to_uncrouch returns true if the player is able to un-crouch.
# @pure
func is_able_to_uncrouch() -> bool:
	assert(uncrouch_shapecast.enabled, "is_able_to_uncrouch can only be called after calling collision.set_uncrouch_shapecast_active(true)")
	return not uncrouch_shapecast.is_colliding()

# is_able_to_attack returns true if the player is able to attack.
# @pure
func is_able_to_attack() -> bool:
	return stamina_system.has_enough(ATTACK_STAMINA_COST)

# is_able_to_wall_hang returns true if the player can hang to the corner of a wall.
# @pure
func is_able_to_wall_hang() -> bool:
	assert(wall_hang_down_raycast.enabled, "is_able_to_wall_hang can only be called after calling collision.set_wall_hang_raycast_active(true)")
	if disable_wall_hang_timeout > 0.0 or wall_hang_down_raycast.is_colliding():
		return false
	if level_node and movement.has_corner_tile_at_hand():
		var corner_pos := movement.get_corner_tile_pos_at_hand()
		var distance_to_corner := position.distance_to(corner_pos)
		return distance_to_corner < 31.0
	return false

# is_able_to_wall_climb returns true if the player can climb to the corner of the wall its currently hanging to.
# @pure
func is_able_to_wall_climb() -> bool:
	assert(wall_climb_stand_shapecast.enabled, "is_able_to_wall_climb can only be called after calling collision.set_wall_climb_shapecast_active(true)")
	return not wall_climb_stand_shapecast.is_colliding() or not wall_climb_crouch_shapecast.is_colliding()

# is_able_to_wall_slide returns true if the player is able to slide along a wall.
# @pure
func is_able_to_wall_slide() -> bool:
	assert(wall_slide_down_raycast.enabled, "is_able_to_wall_slide can only be called after calling set_wall_slide_raycast_active(true)")
	return is_on_wall() and wall_slide_top_side_raycast.is_colliding() and wall_slide_down_side_raycast.is_colliding() and not wall_slide_down_raycast.is_colliding()

###
# Signals handling
###

# @signal
# @impure
func _on_level_level_up(_new_level: int) -> void:
	attack_system.force.value_base = base_force + additional_force_per_level.sample_baked(level_system.level.ratio)
	stamina_system.stamina.max_value_base = base_stamina + additional_stamina_per_level.sample_baked(level_system.level.ratio)
	life_points_system.life_points.max_value_base = base_life_points + additional_life_points_per_level.sample_baked(level_system.level.ratio)

# @signal
# @impure
func _on_stamina_stamina_changed(_stamina: float, stamina_ratio: float, _stamina_previous: float) -> void:
	stamina_ratio_changed.emit(stamina_ratio)

# @signal
# @impure
func _on_life_points_damage_taken(_damage_taken: float, _from_source: Node, _from_instigator: Node) -> void:
	if dead:
		return
	if life_points_system.has_lethal_damage():
		die.call_deferred()
	else:
		hit.call_deferred()

# @signal
# @impure
func _on_life_points_life_points_changed(_life_points: float, life_points_ratio: float, _life_points_previous: float) -> void:
	life_points_ratio_changed.emit(life_points_ratio)
