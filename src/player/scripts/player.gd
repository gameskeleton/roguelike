extends CharacterBody2D
class_name RkPlayer

const JUMP_STRENGTH := -260.0
const CEILING_KNOCKDOWN := 0.0
const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

const ONE_WAY_MARGIN := 2

const RUN_MAX_SPEED := 126.0
const RUN_ACCELERATION := 410.0
const RUN_DECELERATION := 480.0
const RUN_DECELERATION_BRAKE := 1.6

const ROLL_STRENGTH := 220.0
const ROLL_STAMINA_COST := 2.0
const ROLL_DECELERATION := 290.0
const ROLL_BUMP_STRENGTH := -70.0

const ATTACK_MAX_SPEED := 120.0
const ATTACK_STAMINA_COST := 2.0
const ATTACK_ACCELERATION := 310.0
const ATTACK_DECELERATION := 510.0

const STAMINA_MAX := 10.0
const STAMINA_REGEN := 10.0
const STAMINA_BLOCK_REGEN_FOR := 1.5

@onready var sprite: Sprite2D = $Sprite
@onready var roll_detector: Area2D = $RollDetector
@onready var attack_detector: Area2D = $AttackDetector
@onready var one_way_detector: Area2D = $OneWayDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer

###
# State
###

var stamina := STAMINA_MAX
var stamina_regen_blocked_for := 0.0

var direction := 1.0

@onready var fsm := RkStateMachine.new(self, $StateMachine, $StateMachine/stand as RkStateMachineState)

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

# _physics_process is called every physics tick and updates player state.
# @impure
func _physics_process(delta: float):
	process_input(delta)
	process_stamina(delta)
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

# process_stamina regenerates the player stamina if not blocked.
# @impure
func process_stamina(delta: float):
	if stamina_regen_blocked_for > 0.0:
		stamina_regen_blocked_for = max(0.0, stamina_regen_blocked_for - delta)
		if stamina_regen_blocked_for > 0.0:
			return
	stamina = clamp(stamina + delta * STAMINA_REGEN, 0.0, STAMINA_MAX)

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
	return has_stamina(ROLL_STAMINA_COST)

# is_able_to_attack returns true if the player is able to attack.
# @pure
func is_able_to_attack() -> bool:
	return has_stamina(ATTACK_STAMINA_COST)

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
# Stamina
###

# get_stamina returns the stamina between 0 and 1.
# @pure
func get_stamina() -> float:
	return stamina / STAMINA_MAX

# has_stamina returns true if the player has the given of stamina left.
# @pure
func has_stamina(amount := 0.0) -> bool:
	return stamina >= amount

# consume_stamina reduces the stamina by the specified amount, if there is not enough, the stamina will be zeroed.
# the optional parameter bloc_regen_for takes a number of seconds during which the stamina won't be regenerated.
# @impure
func consume_stamina(amount: float, block_regen_for := STAMINA_BLOCK_REGEN_FOR):
	stamina = clamp(stamina - amount, 0.0, STAMINA_MAX)
	stamina_regen_blocked_for = block_regen_for

# try_consume_stamina return true if the player has the given of stamina left and will consume that amount if it does.
# the optional parameter bloc_regen_for takes a number of seconds during which the stamina won't be regenerated.
# @impure
func try_consume_stamina(amount: float, block_regen_for := STAMINA_BLOCK_REGEN_FOR) -> bool:
	if has_stamina(amount):
		consume_stamina(amount, block_regen_for)
		return true
	return false

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
	return clamp(animation_player.current_animation_position / (animation_player.current_animation_length - 0.05), 0.0, 1.0)

###
# Detectors
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
