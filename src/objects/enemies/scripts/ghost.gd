extends Node2D

const SPEED := 2.0
const AMPLITUDE := 8.0
const PROJECTILE_SCENE := preload("res://src/objects/projectiles/fire_ball.tscn")

enum State { appear, idle, shriek, vanish, dying, dead }

@export_group("Nodes")
@export var sprite: Sprite2D
@export var room_notifier: RkRoomNotifier2D
@export var animation_player: AnimationPlayer

@export var drop_system: RkDropSystem
@export var life_points_system: RkLifePointsSystem

@onready var sprite_initial_position := sprite.position

var _hits := 0
var _shot := false
var _timer := 0.0
var _state := State.appear
var _idle_delay := 0.0
var _teleport_position: Vector2

func _ready():
	_teleport_position = position
	life_points_system.life_points.max_value_base = 5.0

func _process(delta: float):
	_timer += delta
	sprite.flip_h = global_position.x < RkMain.get_main_node().player_node.global_position.x
	match _state:
		State.idle: process_idle()
		State.dying: process_dying()
		State.appear: process_appear()
		State.shriek: process_shriek()
		State.vanish: process_vanish()

func set_state(new_state: State):
	match _state:
		State.vanish: finish_vanish()
	_state = new_state
	match new_state:
		State.idle: start_idle()
		State.dead: start_dead()
		State.dying: start_dying()
		State.appear: start_appear()
		State.shriek: start_shriek()
		State.vanish: start_vanish()

func start_idle():
	_timer = 0.0
	_idle_delay = randf_range(1.4, 3.3)
	animation_player.play("idle")

func process_idle():
	position = Vector2(_teleport_position.x, _teleport_position.y + AMPLITUDE * sin(SPEED * _timer))
	if _timer > _idle_delay:
		if not RkMain.get_main_node().player_node.dead:
			set_state(State.shriek)

func start_appear():
	animation_player.play("appear")

func process_appear():
	if animation_player.current_animation == "":
		set_state(State.idle)

func start_shriek():
	_shot = false
	_timer = 0.0
	animation_player.play("shriek")

func process_shriek():
	if _timer > 0.4 and not _shot:
		var projectile_node: RkProjectile = PROJECTILE_SCENE.instantiate()
		_shot = true
		projectile_node.position = position + Vector2(0.0, -24.0)
		projectile_node.direction = (RkMain.get_main_node().player_node.global_position - global_position).normalized()
		projectile_node.damage_type = RkLifePointsSystem.DmgType.fire
		get_parent().add_child(projectile_node)
		projectile_node.owner = get_parent()
	if _timer > 1.0:
		if RkMain.get_main_node().player_node.dead:
			return set_state(State.idle)
		return set_state(State.vanish)

func start_vanish():
	_timer = 0.0
	animation_player.play("vanish")
	life_points_system.invincible = true

func process_vanish():
	if _timer > 0.8:
		_teleport_position = room_notifier.room_node.get_random_free_cell_global_position(3, 3)
		position = _teleport_position
		set_state(State.appear)

func finish_vanish():
	life_points_system.invincible = false

func start_dying():
	animation_player.play("dying")

func process_dying():
	if animation_player.current_animation == "":
		set_state(State.dead)

func start_dead():
	visible = false
	await drop_system.drop(global_position)
	queue_free()

# @signal
func _on_life_points_damage_taken(_damage: float, source: Node, _instigator: Node):
	if life_points_system.has_lethal_damage():
		set_state(State.dying)
	var tween_hit := get_tree().create_tween().bind_node(self)
	var tween_position := get_tree().create_tween().bind_node(self)
	_hits += 1
	sprite.position = sprite_initial_position
	tween_hit.tween_property(sprite.material, "shader_parameter/progress", 2.0, 0.5).from(0.75).set_trans(Tween.TRANS_SINE)
	tween_position.tween_property(sprite, "position", (global_position - source.global_position as Vector2).normalized() * 10.0, 0.1).as_relative().set_trans(Tween.TRANS_LINEAR)
	tween_position.tween_property(sprite, "position", sprite_initial_position, 0.1).set_trans(Tween.TRANS_LINEAR)

# @signal
func _on_room_notifier_2d_player_enter():
	set_process(true)

# @signal
func _on_room_notifier_2d_player_leave():
	set_state(State.appear)
	set_process(false)
