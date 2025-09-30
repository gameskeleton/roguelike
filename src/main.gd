extends Node2D
class_name RkMain

enum State {game, pause, level_up, game_over}

@export_group("Nodes")
@export var level_node: RkLevel
@export var player_node: RkPlayer
@export var object_spawner_node: RkObjectSpawner

@export var level_up_label: RichTextLabel
@export var level_up_animation_player: AnimationPlayer
@export var level_up_audio_stream_player: AudioStreamPlayer

@export var picked_up_label: RichTextLabel
@export var picked_up_animation_player: AnimationPlayer
@export var picked_up_audio_stream_player: AudioStreamPlayer

static var _main_node: RkMain = null

var rng := RandomNumberGenerator.new()
var state := State.game

# @impure
func _init():
	RkMain._main_node = self
	RkWater2D.body_enter = func (water: RkWater2D, body: Node2D):
		if body is CharacterBody2D:
			water.splash(clampi(roundi(body.position.x - water.position.x), 0, water.width - 1), -100.0)

# @impure
func _ready():
	# setup death animation
	player_node.death.connect(func():
		state = State.game_over
		var tween := create_tween()
		tween.parallel().tween_property($CanvasModulate, "color", Color8(0, 0, 0), 1.0)
		tween.parallel().tween_property($GUI/Widgets, "modulate", Color8(0, 0, 0), 1.0)
		tween.parallel().tween_property($AudioStreamPlayer, "volume_db", -80.0, 1.0)
		tween.parallel().tween_callback($DeathAudioStreamPlayer.play).set_delay(0.1)
		tween.tween_property($Game, "modulate", Color8(0, 0, 0), 2.0).set_delay(0.5)
	)
	# setup level up animation
	player_node.level_system.level_up.connect(func(_level: int):
		if state == State.game:
			state = State.level_up
			level_up_animation_player.play(&"level_up!")
		level_up_audio_stream_player.play()
	)

# @impure
func _process(delta: float):
	_process_debug()
	match state:
		State.game: _process_game(delta)
		State.pause: _process_pause(delta)
		State.level_up: _process_level_up()
		State.game_over: _process_game_over()

# @impure
func _process_game(_delta: float):
	# pause game
	if Input.is_action_just_pressed(&"player_pause"):
		state = State.pause
		get_tree().paused = true

# @impure
func _process_debug():
	if player_node.dead:
		return
	if Input.is_action_just_pressed(&"ui_page_up"):
		player_node.level_system.earn_experience(ceili(player_node.level_system.experience_required_to_level_up / 10.0))
	if Input.is_action_just_pressed(&"ui_page_down"):
		player_node.life_points_system.invincibility_delay = 0.0
		player_node.life_points_system.take_damage(ceilf(player_node.life_points_system.life_points.max_value / 10.0))

# @impure
func _process_pause(_delta: float):
	# resume game
	if Input.is_action_just_pressed(&"player_pause"):
		get_tree().paused = false
		state = State.game

# @impure
func _process_level_up():
	if not level_up_animation_player.is_playing():
		get_tree().paused = false
		state = State.game

# @impure
func _process_game_over():
	# reset
	if Input.is_key_pressed(KEY_ENTER):
		get_tree().reload_current_scene()

# @pure
static func get_main_node() -> RkMain:
	return _main_node
