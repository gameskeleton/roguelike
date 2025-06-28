extends CharacterBody2D
class_name RkPlayer

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
const HIT_INVINCIBILITY_DELAY := 1.5

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

const WALL_HANG_DROP_TIMEOUT := 0.3
const WALL_HANG_JUMP_STRENGTH := -200.0
const WALL_HANG_JUMP_EXPULSE_STRENGTH := -100.0

const WALL_SLIDE_JUMP_STRENGTH := -240.0
const WALL_SLIDE_GRAVITY_MAX_SPEED := GRAVITY_MAX_SPEED * 0.2
const WALL_SLIDE_GRAVITY_ACCELERATION := GRAVITY_ACCELERATION * 0.1
const WALL_SLIDE_JUMP_EXPULSE_STRENGTH := -160.0
const WALL_SLIDE_ENTER_MAX_VERTICAL_VELOCITY := 20.0

###
# Nodes
###

@export_group("Nodes")
@export var slot: Node2D
@export var sprite: Sprite2D
@export var level_node: RkLevel
@export var animation_player: AnimationPlayer

@export var collider_stand: CollisionShape2D
@export var collider_crouch: CollisionShape2D

@export var roll_detector: Area2D
@export var slide_detector: Area2D
@export var attack_detector: Area2D
@export var crouch_detector: Area2D
@export var one_way_detector: Area2D
@export var push_wall_roll_detector: Area2D
@export var wall_hang_down_detector: Node2D
@export var wall_climb_stand_detector: Area2D
@export var wall_climb_crouch_detector: Area2D

@export var wall_hang_hand: Node2D
@export var wall_hang_down_raycast: RayCast2D
@export var wall_slide_down_raycast: RayCast2D
@export var wall_slide_side_raycast: RayCast2D
@export var wall_slide_down_side_raycast: RayCast2D

@export var gold_system: RkGoldSystem
@export var level_system: RkLevelSystem
@export var attack_system: RkAttackSystem
@export var stamina_system: RkStaminaSystem
@export var life_points_system: RkLifePointsSystem

@export var coin_picked_up_audio_stream_player: AudioStreamPlayer
@export var experience_picked_up_audio_stream_player: AudioStreamPlayer

###
# Initial values
###

@export_group("Initial values")
@export var direction := 1.0
@export var base_force := 1.0
@export var base_stamina := 10.0
@export var base_life_points := 10.0
@export var additional_force_per_level := Curve.new()
@export var additional_stamina_per_level := Curve.new()
@export var additional_life_points_per_level := Curve.new()

###
# Variables
###

signal death()

@onready var fsm := RkStateMachine.new(self, $StateMachine, $StateMachine/stand as RkStateMachineState)

var dead := false
var crouched := false
var disable_wall_hang_timeout := 0.0
@export var slot_offset := Vector2.ZERO

###
# Input
###

var input_up := RkBufferedInput.new("player_up")
var input_down := RkBufferedInput.new("player_down")
var input_left := RkBufferedInput.new("player_left")
var input_right := RkBufferedInput.new("player_right")
var input_jump := RkBufferedInput.new("player_jump", 0.1)
var input_roll := RkBufferedInput.new("player_roll", 0.1)
var input_slide := RkBufferedInput.new("player_slide", 0.1)
var input_attack := RkBufferedInput.new("player_attack", 0.1)
var input_velocity := Vector2.ZERO

###
# Process
###

# _ready readies the player.
# @impure
func _ready():
	# set default values.
	set_direction(direction)
	_on_level_level_up(level_system.level.value)
	# resplenish system values.
	stamina_system.stamina.resplenish()
	life_points_system.life_points.resplenish()

# _physics_process is called every physics tick and updates the player state.
# @impure
func _physics_process(delta: float):
	process(delta)

# process updates the player state.
# @impure
func process(delta: float):
	process_input(delta)
	process_velocity(delta)
	process_timeouts(delta)
	fsm.process_state_machine(delta)
	if animation_player.is_playing(): animation_player.advance(delta)

# process_input updates player inputs.
# @impure
func process_input(delta: float):
	input_up.process(delta)
	input_down.process(delta)
	input_left.process(delta)
	input_right.process(delta)
	input_jump.process(delta)
	input_roll.process(delta)
	input_slide.process(delta)
	input_attack.process(delta)
	# process input velocity
	input_velocity = Vector2(input_right.to_down_int() - input_left.to_down_int(), input_down.to_down_int() - input_up.to_down_int())

# process_velocity updates player position after applying velocity.
# @impure
func process_velocity(_delta: float):
	move_and_slide()

# process_timeouts decreases timeouts.
# @impure
func process_timeouts(delta: float):
	disable_wall_hang_timeout = maxf(disable_wall_hang_timeout - delta, 0.0)

###
# Movement
###

# die makes the player collapse and emit the death signal
# @impure
func die():
	dead = true
	death.emit()
	fsm.set_state_node(fsm.state_nodes.death)

# hit makes the player hit and invincible for a little while.
# @impure
func hit():
	fsm.set_state_node(fsm.state_nodes.hit)

# dash sets the velocity to the given value scaled by the direction.
# @impure
func dash(slide_velocity: float):
	velocity.x = slide_velocity * direction

# jump applies an impulse to y-velocity.
# @impure
func jump(strength: float):
	velocity.y = strength

# crouch reduces the collider height to crouch size and makes the player crouch.
# @impure
func crouch():
	assert(not crouched)
	crouched = true
	collider_stand.disabled = true
	collider_crouch.disabled = false

# uncrouch increases the collider height to standing size and makes the player un-crouch.
# @impure
func uncrouch():
	assert(crouched)
	crouched = false
	collider_stand.disabled = false
	collider_crouch.disabled = true

# set_direction changes the player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: float):
	direction = new_direction
	sprite.flip_h = new_direction < 0.0
	sprite.offset.x = -9.0 if new_direction < 0.0 else 1.0
	slide_detector.scale.x = new_direction
	attack_detector.scale.x = new_direction
	push_wall_roll_detector.scale.x = new_direction
	wall_hang_down_detector.scale.x = new_direction
	wall_climb_stand_detector.scale.x = new_direction
	wall_climb_crouch_detector.scale.x = new_direction
	wall_slide_side_raycast.target_position.x = abs(wall_slide_side_raycast.target_position.x) * new_direction
	wall_slide_down_side_raycast.target_position.x = abs(wall_slide_down_side_raycast.target_position.x) * new_direction

# handle_gravity applies gravity to the velocity.
# @impure
func handle_gravity(delta: float, max_speed: float, acceleration: float):
	velocity.y = move_toward(velocity.y, max_speed, delta * acceleration)

# handle_direction changes the direction depending on the input velocity.
# @impure
func handle_direction():
	var input_direction := int(signf(input_velocity.x))
	if input_direction != 0.0:
		set_direction(input_direction)

# handle_floor_move applies acceleration or deceleration depending on the input_velocity on the floor.
# @impure
func handle_floor_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if velocity.x == 0.0 or has_same_direction(velocity.x, input_velocity.x):
		velocity.x = apply_acceleration(delta, velocity.x, max_speed, acceleration)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_airborne_move applies acceleration or deceleration depending on the input_velocity while airborne.
# @impure
func handle_airborne_move(delta: float, max_speed: float, acceleration: float, deceleration: float):
	if velocity.x == 0.0 or has_same_direction(velocity.x, input_velocity.x):
		velocity.x = apply_acceleration(delta, velocity.x, max_speed, acceleration, input_velocity.x)
	else:
		handle_deceleration_move(delta, deceleration)

# handle_deceleration_move applies deceleration.
# @impure
func handle_deceleration_move(delta: float, deceleration: float):
	velocity.x = apply_deceleration(delta, velocity.x, deceleration)

# handle_drop_through_one_way positions the player a little down to make it drop through one ways.
# @impure
func handle_drop_through_one_way():
	position.y += ONE_WAY_MARGIN

###
# Maths utils
###

# is_nearly returns true if the first given value nearly equals the second given value.
# @pure
func is_nearly(value1: float, value2: float, epsilon := 0.001) -> bool:
	return absf(value1 - value2) < epsilon

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @pure
func has_same_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0.0 and dir2 != 0.0 and signf(dir1) == signf(dir2)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @pure
func has_invert_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0.0 and dir2 != 0.0 and signf(dir1) != signf(dir2)

# apply_acceleration returns the next value after acceleration is applied.
# @pure
func apply_acceleration(delta: float, value: float, max_speed: float, acceleration: float, override_direction := direction) -> float:
	return move_toward(value, max_speed * signf(override_direction), acceleration * delta)

# apply_deceleration returns the next value after deceleration is applied.
# @pure
func apply_deceleration(delta: float, value: float, deceleration: float) -> float:
	return move_toward(value, 0.0, deceleration * delta)

###
# Checks
###

# is_stopped returns true if the player is nearly stopped.
# @pure
func is_stopped() -> bool:
	return get_real_velocity().length_squared() < 0.1

# is_on_wall_passive returns true if there is a wall in the given direction (defaults to the player's direction).
# note: this is useful if the player is not moving horizontally, whereas is_on_wall only works with a velocity going into a wall.
func is_on_wall_passive(passive_direction := direction) -> bool:
	return test_move(transform, Vector2(2.0 * passive_direction, 0.0))

# is_on_floor_one_way returns true if the player is on the floor and standing on a one way collider.
# note: is_on_floor_one_way will only work if the one way detector was activated with set_one_way_detector_active(true).
# @pure
func is_on_floor_one_way() -> bool:
	return is_on_floor() and one_way_detector.has_overlapping_bodies()

# has_corner_tile_at_hand returns true if there is a corner tile at the wall hang hand's position.
# note: this will only return true if the player is in a level and the wall hang hand is positioned at a corner tile.
# @pure
func has_corner_tile_at_hand() -> bool:
	if not level_node:
		push_warning("has_corner_tile_at_hand should not be called outside of a level")
		return false
	return level_node.has_corner_tile(wall_hang_hand.global_position)

# get_corner_tile_pos_at_hand returns the top-center position of the corner tile at the wall hang hand's position.
# note: this will only return a valid position if the player is in a level and the wall hang hand is positioned at a corner tile.
# @pure
func get_corner_tile_pos_at_hand() -> Vector2:
	assert(level_node, "get_corner_tile_pos_at_hand cannot be called outside of a level")
	assert(has_corner_tile_at_hand(), "get_corner_tile_pos_at_hand called without checking if has_corner_tile_at_hand")
	return level_node.get_corner_tile_pos(wall_hang_hand.global_position)

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
	return not crouch_detector.has_overlapping_bodies()

# is_able_to_attack returns true if the player is able to attack.
# @pure
func is_able_to_attack() -> bool:
	return stamina_system.has_enough(ATTACK_STAMINA_COST)

# is_able_to_wall_hang returns true if the player can hang to the corner of a wall.
# @pure
func is_able_to_wall_hang() -> bool:
	if disable_wall_hang_timeout > 0.0 or wall_hang_down_raycast.is_colliding():
		return false
	if level_node and has_corner_tile_at_hand():
		var corner_pos := get_corner_tile_pos_at_hand()
		var distance_to_corner := position.distance_to(corner_pos)
		return distance_to_corner < 31.0
	return false

# is_able_to_wall_climb returns true if the player can climb to the corner of the wall its currently hanging to.
# @pure
func is_able_to_wall_climb() -> bool:
	return not wall_climb_stand_detector.has_overlapping_bodies() or not wall_climb_crouch_detector.has_overlapping_bodies()

# is_able_to_wall_slide returns true if the player is able to slide along a wall.
# @pure
func is_able_to_wall_slide() -> bool:
	return is_on_wall() and wall_slide_side_raycast.is_colliding() and wall_slide_down_side_raycast.is_colliding() and not wall_slide_down_raycast.is_colliding()

# is_able_to_roll_when_pushing_wall returns true if the player is able to roll under a crouchable section if standing next to a wall.
# @pure
func is_able_to_roll_when_pushing_wall() -> bool:
	return is_able_to_roll() and not push_wall_roll_detector.has_overlapping_bodies()

###
# Sound
###

# stop_sound_effect stops sound effect from playing.
# @impure
func stop_sound_effect(audio_stream_player: AudioStreamPlayer):
	audio_stream_player.stop()

# play_sound_effect plays a sound effect and applies a small random pitch variation.
# @impure
func play_sound_effect(audio_stream_player: AudioStreamPlayer, from_position := 0.0, low_pitch := 0.98, high_pitch := 1.02):
	audio_stream_player.pitch_scale = randf_range(low_pitch, high_pitch)
	audio_stream_player.play(from_position)

###
# Animation
###

# play_animation changes the player animation to the given animation name.
# @impure
func play_animation(animation_name: StringName):
	if not is_animation_playing(animation_name):
		animation_player.play(animation_name)

# play_animation_transition transitions the player animation from start to then when start finishes.
# @impure
func play_animation_transition(start_animation_name: StringName, then_animation_name: StringName):
	if not is_animation_playing(start_animation_name):
		play_animation(then_animation_name)

# is_animation_playing returns true if the given animation is playing.
# @pure
func is_animation_playing(animation: StringName) -> bool:
	return animation_player.current_animation == animation

# is_animation_finished returns true if the animation is finished (and not looping).
# @pure
func is_animation_finished() -> bool:
	return animation_player.current_animation_position >= animation_player.current_animation_length - 0.001

# get_animation_played_ratio returns the ratio of the animation played by its length.
# @impure
func get_animation_played_ratio() -> float:
	return clampf(animation_player.current_animation_position / (animation_player.current_animation_length - 0.001), 0.0, 1.0)

###
# Raycasts and detectors
###

# set_roll_detector_active activates or deactivates the monitoring for destroying decors when rolling.
# @impure
func set_roll_detector_active(active: bool):
	roll_detector.monitoring = active
	roll_detector.monitorable = active

# set_slide_detector_active activates or deactivates the monitoring for destroying decors when sliding.
# @impure
func set_slide_detector_active(active: bool):
	slide_detector.monitoring = active
	slide_detector.monitorable = active

# set_attack_detector_active activates or deactivates the monitoring for attack colliders.
# @impure
func set_attack_detector_active(active: bool):
	attack_detector.monitoring = active
	attack_detector.monitorable = active

# set_crouch_detector_active activates or deactivates the monitoring for crouch colliders.
# @impure
func set_crouch_detector_active(active: bool):
	crouch_detector.monitoring = active
	crouch_detector.monitorable = active

# set_one_way_detector_active activates or deactivates the monitoring for one way colliders.
# @impure
func set_one_way_detector_active(active: bool):
	one_way_detector.monitoring = active
	one_way_detector.monitorable = active

# set_wall_hang_detector_active activates or deactivates the monitoring for hanging to a wall.
# @impure
func set_wall_hang_detector_active(active: bool):
	wall_hang_down_raycast.enabled = active

# set_wall_climb_detector_active activates or deactivates the monitoring for climbing to a wall.
# @impure
func set_wall_climb_detector_active(active: bool):
	wall_climb_stand_detector.monitoring = active
	wall_climb_stand_detector.monitorable = active
	wall_climb_crouch_detector.monitoring = active
	wall_climb_crouch_detector.monitorable = active

# set_wall_slide_raycast_active activates or deactivates the raycast to check if wall slide is possible and safe.
# @impure
func set_wall_slide_raycast_active(active: bool):
	wall_slide_down_raycast.enabled = active
	wall_slide_side_raycast.enabled = active
	wall_slide_down_side_raycast.enabled = active

# set_push_wall_roll_detector_active activates or deactivates the monitoring for safely rolling under a crouchable section.
# @impure
func set_push_wall_roll_detector_active(active: bool):
	push_wall_roll_detector.monitoring = active
	push_wall_roll_detector.monitorable = active

###
# Signals
###

# @signal
# @impure
func _on_level_level_up(_new_level: int):
	attack_system.force.value_base = base_force + additional_force_per_level.sample_baked(level_system.level.ratio)
	stamina_system.stamina.max_value_base = base_stamina + additional_stamina_per_level.sample_baked(level_system.level.ratio)
	life_points_system.life_points.max_value_base = base_life_points + additional_life_points_per_level.sample_baked(level_system.level.ratio)

# @signal
# @impure
func _on_life_points_damage_taken(_damage_taken: float, _source: Node, _instigator: Node):
	if not dead:
		(die if life_points_system.has_lethal_damage() else hit).call_deferred()
