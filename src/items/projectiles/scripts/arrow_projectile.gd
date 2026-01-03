extends RkProjectile

@export var speed := 600.0
@export var gravity := 800.0
@export var bounce_factor := 0.6
@export var bounce_threshold := 200.0

var stuck := false
var direction := Vector2.RIGHT

# @impure
func _ready() -> void:
	velocity = direction * speed
	if scale.x < 0:
		scale.x = 1.0
	rotation = velocity.angle()

# @impure
func _physics_process(delta: float) -> void:
	if stuck:
		return
	velocity.y += gravity * delta
	rotation = velocity.angle()
	var collision := move_and_collide(velocity * delta)
	if collision:
		var normal := collision.get_normal()
		if absf(normal.y) > 0.5 and absf(velocity.y) > bounce_threshold:
			velocity.x *= 0.8
			velocity.y = -velocity.y * bounce_factor
			return
		stick()

# @impure
func stick() -> void:
	stuck = true
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	set_physics_process(false)
	await get_tree().create_timer(2.0).timeout
	destroy_projectile()
