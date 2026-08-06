extends CharacterBody2D

const MAX_SPEED := 40.0
const ACCELERATION := 100.0

const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

const HITSTUN_IMPULSE := Vector2(90.0, -60.0)
const HITSTUN_DURATION := 0.25
const HITSTOP_DURATION := 0.06
const HITSTUN_DECELERATION := 260.0

const BOW_COOLDOWN_DURATION := 1.4
const BOW_WINDUP_DURATION := 0.35

var direction := 1.0

@export var contact_damage := 1.0
@export var contact_damage_type := RkLifePointsSystem.DmgType.physical

@export_group(&"Bow")
@export var arrow_scene: PackedScene
@export var arrow_damage := 2.0
@export var arrow_damage_type := RkLifePointsSystem.DmgType.physical

@export_group(&"References")
@export var sprite: ColorRect
@export var bow_marker: Marker2D
@export var detection_area: Area2D
@export var line_of_sight_raycast: RayCast2D

@export_group(&"Systems")
@export var attack_system: RkAttackSystem
@export var life_points_system: RkLifePointsSystem

var target: RkPlayer

var aiming := false
var cooldown_timeout := 0.0
var windup_timeout := 0.0

var hit_tween: Tween
var hitstop_timeout := 0.0
var hitstun_timeout := 0.0
var base_sprite_color: Color

var windup_tween: Tween

# @impure
func _ready() -> void:
	# scenes
	assert(arrow_scene != null, "arrow_scene not set")
	# references
	assert(sprite != null, "sprite not set")
	assert(bow_marker != null, "bow_marker not set")
	assert(detection_area != null, "detection_area not set")
	assert(line_of_sight_raycast != null, "line_of_sight_raycast not set")
	# systems
	assert(attack_system != null, "attack_system not set")
	assert(life_points_system != null, "life_points_system not set")
	# signals
	attack_system.attacked.connect(_on_attack_system_attacked)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	# save base color to restore when hit
	base_sprite_color = sprite.color
	set_direction(direction)

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
		var can_see_target := _update_line_of_sight()
		if can_see_target:
			velocity.x = move_toward(velocity.x, 0.0, delta * ACCELERATION)
			set_direction(signf(target.global_position.x - global_position.x))
			_process_attack(delta)
		else:
			_cancel_attack()
			velocity.x = move_toward(velocity.x, MAX_SPEED * direction, delta * ACCELERATION)
	velocity.y = move_toward(velocity.y, GRAVITY_MAX_SPEED, delta * GRAVITY_ACCELERATION)
	move_and_slide()
	if is_on_wall() and hitstun_timeout <= 0.0 and target == null:
		set_direction(direction * -1.0)

# _update_line_of_sight points the raycast at the current target and returns true if it is unobstructed.
# @impure
func _update_line_of_sight() -> bool:
	if target == null:
		return false
	line_of_sight_raycast.target_position = line_of_sight_raycast.to_local(target.global_position)
	line_of_sight_raycast.force_raycast_update()
	return not line_of_sight_raycast.is_colliding()

# _process_attack handles the windup/cooldown of the bow and fires an arrow once ready.
# @impure
func _process_attack(delta: float) -> void:
	if cooldown_timeout > 0.0:
		cooldown_timeout = maxf(cooldown_timeout - delta, 0.0)
		return
	if not aiming:
		aiming = true
		windup_timeout = BOW_WINDUP_DURATION
		_play_windup_effect()
		return
	windup_timeout = maxf(windup_timeout - delta, 0.0)
	if windup_timeout <= 0.0:
		_shoot_arrow()
		aiming = false
		cooldown_timeout = BOW_COOLDOWN_DURATION
		_stop_windup_effect()

# _cancel_attack aborts any in-progress windup, e.g. when the target is lost.
# @impure
func _cancel_attack() -> void:
	if aiming:
		aiming = false
		windup_timeout = 0.0
		_stop_windup_effect()

# _shoot_arrow spawns an arrow aimed at the current direction.
# @impure
func _shoot_arrow() -> void:
	var arrow_node := arrow_scene.instantiate()
	arrow_node.scale.x = -1.0 if direction < 0.0 else 1.0
	arrow_node.direction = Vector2(direction, 0.0)
	arrow_node.damage = arrow_damage
	arrow_node.damage_type = arrow_damage_type
	arrow_node.global_position = bow_marker.global_position
	get_parent().add_child(arrow_node)
	arrow_node.attack_system.source = self
	arrow_node.attack_system.instigator = self

# set_direction changes the skeleton direction and mirrors its references accordingly.
# @impure
func set_direction(new_direction: float) -> void:
	if new_direction == 0.0:
		return
	direction = new_direction
	bow_marker.position.x = absf(bow_marker.position.x) * direction

# hitstop briefly freezes the skeleton in place to sell the impact of a hit.
# @impure
func hitstop(duration: float) -> void:
	hitstop_timeout = maxf(hitstop_timeout, duration)

# _enter_hitstun stuns the skeleton for a short while and knocks it away from its attacker.
# @impure
func _enter_hitstun(from_instigator: Node) -> void:
	if hitstun_timeout <= 0.0:
		life_points_system.invincible += 0 # CHECKME: not sure for now
	hitstun_timeout = HITSTUN_DURATION
	_cancel_attack()
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

# _play_windup_effect telegraphs that the skeleton is about to loose an arrow.
# @impure
func _play_windup_effect() -> void:
	if windup_tween:
		windup_tween.kill()
	windup_tween = get_tree().create_tween()
	windup_tween.tween_property(sprite, ^"color", Color.YELLOW, BOW_WINDUP_DURATION)

# @impure
func _stop_windup_effect() -> void:
	if windup_tween:
		windup_tween.kill()
		windup_tween = null
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
func _on_attack_system_attacked(target_life_points: RkLifePointsSystem, _damage: float, _damage_type: RkLifePointsSystem.DmgType) -> void:
	if target_life_points.hitstun:
		hitstop(HITSTOP_DURATION)

# @signal
# @impure
func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	var target_life_points_system := RkLifePointsSystem.find_system_node(body)
	if target_life_points_system:
		attack_system.attack(target_life_points_system, contact_damage, contact_damage_type)

# @signal
# @impure
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is RkPlayer:
		target = body as RkPlayer

# @signal
# @impure
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		_cancel_attack()
