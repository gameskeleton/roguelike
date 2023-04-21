extends CharacterBody2D
class_name RkPlayer

const ONE_WAY_MARGIN := 2

const JUMP_STRENGTH := -260.0
const CEILING_KNOCKDOWN := 0.0
const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

const HIT_IMPULSE := Vector2(140.0, -140.0)
const HIT_INVINCIBILITY_DELAY := 1.5

const RUN_MAX_SPEED := 126.0
const RUN_ACCELERATION := 410.0
const RUN_DECELERATION := 480.0
const RUN_DECELERATION_BRAKE := 1.6

const ROLL_DAMAGE := 1.0
const ROLL_STRENGTH := 220.0
const ROLL_STAMINA_COST := 2.0
const ROLL_DECELERATION := 290.0
const ROLL_BUMP_STRENGTH := -70.0

const WALL_JUMP_STRENGTH := -230.0
const WALL_JUMP_EXPULSE_STRENGTH := -160.0

const WALL_SLIDE_GRAVITY_MAX_SPEED := GRAVITY_MAX_SPEED * 0.2
const WALL_SLIDE_GRAVITY_ACCELERATION := GRAVITY_ACCELERATION * 0.1
const WALL_SLIDE_ENTER_MAX_VERTICAL_VELOCITY := 20.0

const ATTACK_DAMAGE := 1.0
const ATTACK_MAX_SPEED := 120.0
const ATTACK_STAMINA_COST := 2.0
const ATTACK_ACCELERATION := 310.0
const ATTACK_DECELERATION := 510.0

###
# Nodes
###

@onready var fsm := RkStateMachine.new(self, $StateMachine, $StateMachine/stand as RkStateMachineState)
@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var roll_detector: Area2D = $RollDetector
@onready var attack_detector: Area2D = $AttackDetector
@onready var one_way_detector: Area2D = $OneWayDetector
@onready var wall_hang_up_detector: Area2D = $WallHangUpDetector
@onready var wall_hang_down_raycast: RayCast2D = $WallHangDownSideRaycast
@onready var wall_hang_down_detector: Area2D = $WallHangDownDetector
@onready var wall_slide_down_raycast: RayCast2D = $WallSlideDownRaycast
@onready var wall_slide_side_raycast: RayCast2D = $WallSlideSideRaycast
@onready var wall_slide_down_side_raycast: RayCast2D = $WallSlideDownSideRaycast

###
# State
###

@export var direction := 1.0
@export var base_force := 1.0
@export var base_stamina := 10.0
@export var base_life_points := 10.0
@export var additional_force_per_level := Curve.new()
@export var additional_stamina_per_level := Curve.new()
@export var additional_life_points_per_level := Curve.new()

@onready var gold_system: RkGoldSystem = $Systems/Gold
@onready var level_system: RkLevelSystem = $Systems/Level
@onready var attack_system: RkAttackSystem = $Systems/Attack
@onready var stamina_system: RkStaminaSystem = $Systems/Stamina
@onready var inventory_system: RkInventorySystem = $Systems/Inventory
@onready var life_points_system: RkLifePointsSystem = $Systems/LifePoints

###
# Input
###

var input_up := 0.0
var input_down := 0.0
var input_left := 0.0
var input_right := 0.0
var input_jump := 0.0
var input_roll := 0.0
var input_attack := 0.0
var input_velocity := Vector2.ZERO

###
# Process
###

# _ready readies the player.
# @impure
func _ready():
	set_direction(direction)
	_on_level_level_up(level_system.level)
	# resplenish system values to account for inventory default slots modifiers
	attack_system.force.resplenish()
	stamina_system.stamina.resplenish()
	life_points_system.life_points.resplenish()

# _physics_process is called every physics tick and updates player state.
# @impure
func _physics_process(delta: float):
	process_input(delta)
	process_velocity(delta)
	fsm.process_state_machine(delta)

# process_input updates player inputs.
# @impure
func process_input(delta: float):
	var up := Input.is_action_pressed("player_up")
	var down := Input.is_action_pressed("player_down")
	var left := Input.is_action_pressed("player_left")
	var right := Input.is_action_pressed("player_right")
	# compute input held
	input_up = input_up + delta if up else 0.0
	input_down = input_down + delta if down else 0.0
	input_left = input_left + delta if left else 0.0
	input_right = input_right + delta if right else 0.0
	input_jump = input_jump + delta if Input.is_action_pressed("player_jump") else 0.0
	input_roll = input_roll + delta if Input.is_action_pressed("player_roll") else 0.0
	input_attack = input_attack + delta if Input.is_action_pressed("player_attack") else 0.0
	# compute input velocity
	input_velocity = Vector2(int(right) - int(left), int(down) - int(up))

# process_velocity updates player position after applying velocity.
# @impure
func process_velocity(_delta: float):
	move_and_slide()

###
# Input
###

# input_pressed return true if the given input buffer is pressed.
# @pure
func input_pressed(input: float) -> bool:
	return input > 0.0

# input_just_pressed return true if the given input was just pressed.
# @pure
func input_just_pressed(input: float, buffer := 2.0 / 60.0) -> bool:
	return input > 0.0 and input <= buffer

###
# Movement
###

# set_direction changes the player direction and flips the sprite accordingly.
# @impure
func set_direction(new_direction: float):
	direction = new_direction
	sprite.flip_h = new_direction < 0.0
	sprite.offset.x = -8 if new_direction < 0.0 else 1
	attack_detector.scale.x = new_direction
	wall_hang_up_detector.position.x = abs(wall_hang_up_detector.position.x) * new_direction
	wall_hang_down_detector.position.x = abs(wall_hang_down_detector.position.x) * new_direction
	wall_slide_side_raycast.target_position.x = abs(wall_slide_side_raycast.target_position.x) * new_direction
	wall_slide_down_side_raycast.target_position.x = abs(wall_slide_down_side_raycast.target_position.x) * new_direction

# handle_jump applies sudden strength to y-velocity.
# @impure
func handle_jump(strength: float):
	velocity.y = strength

# handle_roll applies sudden strength to x-velocity.
# @impure
func handle_roll(strength: float):
	velocity.x = strength

# handle_gravity applies gravity to the velocity.
# @impure
func handle_gravity(delta: float, max_speed: float, acceleration: float):
	velocity.y = move_toward(velocity.y, max_speed, delta * acceleration)

# handle_direction changes the direction depending on the input velocity.
# @impure
func handle_direction():
	var input_direction := int(sign(input_velocity.x))
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

# is_nearly returns true if the first given value nearly equals the second given value.
# @pure
func is_nearly(value1: float, value2: float, epsilon = 0.001) -> bool:
	return abs(value1 - value2) < epsilon

# has_same_direction returns true if the two given numbers are non-zero and of the same sign.
# @pure
func has_same_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0.0 and dir2 != 0.0 and sign(dir1) == sign(dir2)

# has_invert_direction returns true if the two given numbers are non-zero and of the opposed sign.
# @pure
func has_invert_direction(dir1: float, dir2: float) -> bool:
	return dir1 != 0.0 and dir2 != 0.0 and sign(dir1) != sign(dir2)

# apply_acceleration returns the next value after acceleration is applied.
# @pure
func apply_acceleration(delta: float, value: float, max_speed: float, acceleration: float, override_direction = direction) -> float:
	return move_toward(value, max_speed * sign(override_direction), acceleration * delta)

# apply_deceleration returns the next value after deceleration is applied.
# @pure
func apply_deceleration(delta: float, value: float, deceleration: float) -> float:
	return move_toward(value, 0.0, deceleration * delta)

# get_corner_position returns the snapped position to the nearest corner wall.
# @pure
func get_corner_position() -> Vector2:
	return Vector2(
		floor(floor(position.x / 16.0) * 16.0) + (16.0 if direction > 0 else 0.0),
		floor(floor(position.y / 16.0) * 16.0)
	)

###
# Checks
###

# is_stopped returns true if the player is nearly stopped.
# @pure
func is_stopped() -> bool:
	return get_real_velocity().length_squared() < 0.1

# is_able_to_jump returns true if the player is able to jump.
# @pure
func is_able_to_jump() -> bool:
	return true

# is_able_to_roll returns true if the player is able to roll.
# @pure
func is_able_to_roll() -> bool:
	return stamina_system.has_enough(ROLL_STAMINA_COST)

# is_able_to_attack returns true if the player is able to attack.
# @pure
func is_able_to_attack() -> bool:
	return stamina_system.has_enough(ATTACK_STAMINA_COST)

# is_able_to_wall_hang returns true if the player is near a corner wall.
# @pure
func is_able_to_wall_hang() -> bool:
	return is_on_wall() and not wall_hang_down_raycast.is_colliding() and wall_hang_down_detector.has_overlapping_bodies() and not wall_hang_up_detector.has_overlapping_bodies()

# is_able_to_wall_slide returns true if the player is able to slide on a wall.
# @pure
func is_able_to_wall_slide() -> bool:
	return is_on_wall() and wall_slide_side_raycast.is_colliding() and wall_slide_down_side_raycast.is_colliding() and not wall_slide_down_raycast.is_colliding()

# is_on_wall_passive returns true if there is a wall in the player's direction.
# note: this is useful if the player is not moving horizontally, whereas is_on_wall only work with a velocity going into a wall.
func is_on_wall_passive() -> bool:
	return is_on_wall() or test_move(transform, Vector2.RIGHT * direction)

# is_on_floor_one_way returns true if the player is on the floor and standing on a one way collider.
# note: is_on_floor_one_way will only work if the one way detector was activated with set_one_way_detector_active(true).
# @pure
func is_on_floor_one_way() -> bool:
	return is_on_floor() and one_way_detector.has_overlapping_bodies()

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
func play_animation(animation_name: String):
	if not is_animation_playing(animation_name):
		animation_player.play(animation_name)

# play_animation_transition transitions the player animation from start to then.
# @impure
func play_animation_transition(start_animation_name: String, then_animation_name: String):
	if is_animation_playing(start_animation_name) and is_animation_finished():
		play_animation(then_animation_name)

# is_animation_playing returns true if the given animation is playing.
# @pure
func is_animation_playing(animation: String) -> bool:
	return animation_player.current_animation == animation

# is_animation_finished returns true if the animation is finished (and not looping).
# @pure
func is_animation_finished() -> bool:
	return animation_player.current_animation_position >= animation_player.current_animation_length - 0.001

# get_animation_played_ratio returns the ratio of the animation played by its length.
# @impure
func get_animation_played_ratio() -> float:
	return clampf(animation_player.current_animation_position / (animation_player.current_animation_length - 0.05), 0.0, 1.0)

###
# Raycasts and detectors
###

# set_roll_detector_active activates or deactivates the monitoring for decors colliders.
# @impure
func set_roll_detector_active(active: bool):
	roll_detector.monitoring = active
	roll_detector.monitorable = active

# set_attack_detector_active activates or deactivates the monitoring for attack colliders.
# @impure
func set_attack_detector_active(active: bool):
	attack_detector.monitoring = active
	attack_detector.monitorable = active

# set_one_way_detector_active activates or deactivates the monitoring for one way colliders.
# @impure
func set_one_way_detector_active(active: bool):
	one_way_detector.monitoring = active
	one_way_detector.monitorable = active

# set_wall_hang_detector_active activates or deactivates the monitoring for hanging/climbing to a wall.
# @impure
func set_wall_hang_detector_active(active: bool):
	wall_hang_up_detector.monitoring = active
	wall_hang_up_detector.monitorable = active
	wall_hang_down_raycast.enabled = active
	wall_hang_down_detector.monitoring = active
	wall_hang_down_detector.monitorable = active

# set_wall_slide_raycast_active activates or deactivates the raycast to check if wall slide is possible and safe.
# @impure
func set_wall_slide_raycast_active(active: bool):
	wall_slide_down_raycast.enabled = active
	wall_slide_side_raycast.enabled = active
	wall_slide_down_side_raycast.enabled = active

###
# Signals
###

# @signal
# @impure
func _on_level_level_up(_new_level: int):
	attack_system.force.max_value_base = base_force + additional_force_per_level.sample_baked(level_system.ratio)
	stamina_system.stamina.max_value_base = base_stamina + additional_stamina_per_level.sample_baked(level_system.ratio)
	life_points_system.life_points.max_value_base = base_life_points + additional_life_points_per_level.sample_baked(level_system.ratio)

# @signal
# @impure
func _on_life_points_damage_taken(_damage_taken: float, _source: Node, _instigator: Node):
	fsm.call_deferred("set_state_node", fsm.state_nodes.hit)
