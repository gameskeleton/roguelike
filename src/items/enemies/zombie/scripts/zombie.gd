extends CharacterBody2D

const MAX_SPEED := 50.0
const ACCELERATION := 100.0

const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

const HITSTUN_IMPULSE := Vector2(90.0, -60.0)
const HITSTUN_DURATION := 0.25
const HITSTOP_DURATION := 0.06
const HITSTUN_DECELERATION := 260.0

var direction := 1.0

@export var damage := 3.0
@export var damage_type := RkLifePointsSystem.DmgType.physical

@export_group(&"References")
@export var sprite: ColorRect

@export_group(&"Systems")
@export var attack_system: RkAttackSystem
@export var life_points_system: RkLifePointsSystem

var hit_tween: Tween
var hitstop_timeout := 0.0
var hitstun_timeout := 0.0
var base_sprite_color: Color

# @impure
func _ready() -> void:
	# references
	assert(sprite != null, "sprite not set")
	assert(attack_system != null, "attack_system not set")
	assert(life_points_system != null, "life_points_system not set")
	# signals
	attack_system.attacked.connect(_on_attack_system_attacked)
	# save base color to restore when hit
	base_sprite_color = sprite.color

# @impure
func _physics_process(delta: float) -> void:
	if hitstop_timeout > 0.0:
		hitstop_timeout = maxf(hitstop_timeout - delta, 0.0)
		return
	if hitstun_timeout > 0.0:
		hitstun_timeout = maxf(hitstun_timeout - delta, 0.0)
		velocity.x = move_toward(velocity.x, 0.0, delta * HITSTUN_DECELERATION)
		if hitstun_timeout == 0.0:
			_exit_hitstun()
	else:
		velocity.x = move_toward(velocity.x, MAX_SPEED * direction, delta * ACCELERATION)
	velocity.y = move_toward(velocity.y, GRAVITY_MAX_SPEED, delta * GRAVITY_ACCELERATION)
	move_and_slide()
	if is_on_wall() and hitstun_timeout <= 0.0:
		direction *= -1.0

# hitstop briefly freezes the zombie in place to sell the impact of a hit.
# @impure
func hitstop(duration: float) -> void:
	hitstop_timeout = maxf(hitstop_timeout, duration)

# _enter_hitstun stuns the zombie for a short while and knocks it away from its attacker.
# @impure
func _enter_hitstun(from_instigator: Node) -> void:
	if hitstun_timeout <= 0.0:
		life_points_system.invincible += 0 # CHECKME: not sure for now
	hitstun_timeout = HITSTUN_DURATION
	var knockback_direction := direction
	if from_instigator is Node2D:
		knockback_direction = signf(global_position.x - (from_instigator as Node2D).global_position.x)
		if knockback_direction == 0.0:
			knockback_direction = direction
	velocity = Vector2(knockback_direction * HITSTUN_IMPULSE.x, HITSTUN_IMPULSE.y)
	_play_hit_effect()

# @impure
func _exit_hitstun() -> void:
	life_points_system.invincible -= 0 # CHECKME: not sure for now
	_stop_hit_effect()

# @impure
func _play_hit_effect() -> void:
	if hit_tween:
		hit_tween.kill()
	hit_tween = get_tree().create_tween().set_loops()
	hit_tween.tween_property(sprite, ^"color", Color.WHITE, 0.05)
	hit_tween.tween_property(sprite, ^"color", base_sprite_color, 0.05)

# @impure
func _stop_hit_effect() -> void:
	if hit_tween:
		hit_tween.kill()
		hit_tween = null
	sprite.color = base_sprite_color

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, _from_source: Node, from_instigator: Node) -> void:
	if life_points_system.has_lethal_damage():
		queue_free()
		return
	_enter_hitstun(from_instigator)

# @signal
# @impure
func _on_attack_system_attacked(_target_life_points: RkLifePointsSystem, _damage: float, _damage_type: RkLifePointsSystem.DmgType) -> void:
	hitstop(HITSTOP_DURATION)

# @signal
# @impure
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	var target_life_points_system := RkLifePointsSystem.find_system_node(body)
	if target_life_points_system:
		attack_system.attack(target_life_points_system, damage, damage_type)
