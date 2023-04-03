extends Node2D

enum State {
	idle,
	lock,
	fire
}

const LOCK_DELAY := 1.0
const FIRE_DELAY := 0.6
const FIRE_COOLDOWN := 0.1

@export var projectile_scene := preload("res://src/items/projectiles/fire_ball.tscn")

var _timer := 0.0
var _state := State.idle
var _player_node: RkPlayer

# @impure
func _ready():
	_player_node = RkMain.get_main_node(self).player_node
	_on_player_leave_room()

# @impure
func _process(delta: float):
	$AnimatedSprite2D.flip_h = _player_node.global_position.x < global_position.x
	match _state:
		State.idle:
			_timer += delta
			if _timer > LOCK_DELAY:
				_state = State.lock
				_timer = 0.0
				_lock()
		State.lock:
			_timer += delta
			if _timer > FIRE_DELAY:
				_state = State.fire
				_timer = 0.0
				_fire()
		State.fire:
			_timer += delta
			if _timer > FIRE_COOLDOWN:
				_state = State.idle
				_timer = 0.0

# @impure
func _lock():
	$AnimationPlayer.play("lock")

# @impure
func _fire():
	var projectile_node: RkProjectile = projectile_scene.instantiate()
	projectile_node.position = Vector2(-5, -4) if $AnimatedSprite2D.flip_h else Vector2(5, -4)
	projectile_node.direction = (_player_node.global_position - global_position).normalized()
	projectile_node.damage_type = RkLifePoints.DmgType.fire
	add_child(projectile_node)
	$AnimationPlayer.play("RESET")

# @impure
func _reset():
	_timer = 0.0

# @signal
# @impure
func _on_damage_taken(_damage: float, life_points: float, _instigator: Object):
	if life_points <= 0.0:
		queue_free()

# @signal
# @impure
func _on_player_enter_room():
	set_process(true)
	set_physics_process(true)

# @signal
# @impure
func _on_player_leave_room():
	_reset()
	set_process(false)
	set_physics_process(false)
