extends RkProjectile

@export var speed := 600.0
@export var gravity := 918.0
@export var bounce_slowdown := Vector2(0.8, -0.6)
@export var bounce_max_angle := 35.0
@export var bounce_min_velocity := 390.0

@export_group(&"References")
@export var audio_stream_player: AudioStreamPlayer2D

var stuck := false
var direction := Vector2.RIGHT

# @impure
func _ready() -> void:
	# references
	assert(audio_stream_player != null, "audio_stream_player not set")
	# apply initial velocity and rotation
	velocity = direction * speed
	if scale.x < 0:
		scale.x = 1.0
	rotation = velocity.angle()

# @impure
func _physics_process(delta: float) -> void:
	if stuck:
		return
	rotation = velocity.angle()
	velocity += -up_direction * gravity * delta
	var collision := move_and_collide(velocity * delta)
	if collision:
		var normal := collision.get_normal()
		var tangent := normal.rotated(PI * 0.5)
		if tangent.dot(up_direction) < 0:
			tangent = -tangent
		var angle_impact := velocity.angle_to(tangent)
		var angle_to_line := minf(absf(angle_impact), PI - absf(angle_impact))
		if angle_to_line < deg_to_rad(bounce_max_angle) and velocity.length() > bounce_min_velocity:
			velocity *= bounce_slowdown
			return
		stick()

# @impure
func stick() -> void:
	stuck = true
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	audio_stream_player.play()
	set_physics_process(false)
	await get_tree().create_timer(2.0).timeout
	destroy_projectile()
