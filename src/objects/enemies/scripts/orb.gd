extends Node2D

enum State { idle, lock, fire }

const PROJECTILE_SCENE := preload("res://src/objects/projectiles/fire_ball.tscn")

const LOCK_DELAY := 1.1
const FIRE_DELAY := 0.6
const FIRE_COOLDOWN := 0.1

const EXPULSE_SPEED := 8.0
const EXPULSE_STRENGTH := 10.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var life_points_system: RkLifePointsSystem = $Systems/LifePoints

var _timer := 0.0
var _state := State.idle
var _expulse: Vector2
var _player_node: RkPlayer
var _expulse_alpha := 1.0

var _lock_delay := LOCK_DELAY
var _fire_delay := FIRE_DELAY
var _fire_cooldown := FIRE_COOLDOWN

# @impure
func _ready():
	_player_node = RkMain.get_main_node(self).player_node
	_reset()
	_on_room_notifier_2d_player_leave()
	life_points_system.life_points.max_value_base = 5.0

# @impure
func _process(delta: float):
	if _expulse_alpha > 0.0 and _expulse_alpha <= 0.5:
		_expulse_alpha -= EXPULSE_SPEED * delta
		animated_sprite.offset = lerp(Vector2.ZERO, _expulse, _expulse_alpha)
	if _expulse_alpha > 0.5:
		_expulse_alpha -= EXPULSE_SPEED * delta
		animated_sprite.offset = lerp(_expulse, Vector2.ZERO, _expulse_alpha - 0.5)
	animated_sprite.flip_h = _player_node.global_position.x < global_position.x
	match _state:
		State.idle:
			_timer += delta
			if _timer > _lock_delay:
				_state = State.lock
				_timer = 0.0
				_lock()
		State.lock:
			_timer += delta
			if _timer > _fire_delay:
				_state = State.fire
				_timer = 0.0
				_fire()
		State.fire:
			_timer += delta
			if _timer > _fire_cooldown:
				_state = State.idle
				_timer = 0.0
				_randomize_timings()

# @impure
func _lock():
	animation_player.play("lock")

# @impure
func _fire():
	var projectile_node: RkProjectile = PROJECTILE_SCENE.instantiate()
	projectile_node.position = Vector2(-5, -4) if animated_sprite.flip_h else Vector2(5, -4)
	projectile_node.direction = (_player_node.global_position - global_position).normalized()
	projectile_node.damage_type = RkLifePointsSystem.DmgType.fire
	add_child(projectile_node)
	projectile_node.owner = self
	animation_player.play("RESET")

# @impure
func _reset():
	_timer = 0.0
	_state = State.idle
	_randomize_timings()

# @impure
func _randomize_timings():
	_lock_delay = LOCK_DELAY + randf_range(0.0, 0.5)
	_fire_delay = FIRE_DELAY + randf_range(0.0, 0.5)
	_fire_cooldown = FIRE_COOLDOWN + randf_range(0.0, 0.5)

# @signal
# @impure
func _on_life_points_damage_taken(_damage: float, source: Node, _instigator: Node):
	_reset()
	_expulse = (global_position - source.global_position).normalized() * EXPULSE_STRENGTH
	_expulse_alpha = 1.0
	animation_player.play("hit")
	if life_points_system.has_lethal_damage():
		RkPickupSpawner.try_spawn_coins(self, global_position, randi_range(0, 3))
		RkPickupSpawner.try_spawn_experiences(self, global_position, randi_range(6, 7))
		queue_free()

# @signal
# @impure
func _on_room_notifier_2d_player_enter():
	_reset()
	set_process(true)
	set_physics_process(true)

# @signal
# @impure
func _on_room_notifier_2d_player_leave():
	_reset()
	set_process(false)
	set_physics_process(false)