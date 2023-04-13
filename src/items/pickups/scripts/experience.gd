extends RigidBody2D
class_name RkPickupExperience

const PICKUP_DELAY := 0.35
const IMPULSE_STRENGTH := 30.0

@export var value := 1

@onready var line: Line2D = $Node/Line2D
@onready var player_detector: Area2D = $PlayerDetector

# @impure
func _ready():
	# add random impulse
	apply_central_impulse(IMPULSE_STRENGTH * Vector2(randf_range(-5.0, 5.0), randf_range(-4.0, -6.0)))
	# enable pickup after a while
	await get_tree().create_timer(PICKUP_DELAY, false).timeout
	player_detector.monitoring = true
	player_detector.monitorable = true

# @impure
func _process(_delta: float):
	if linear_velocity.length_squared() > 2:
		line.add_point(global_position)
		while line.get_point_count() > 20:
			line.remove_point(0)
	else:
		line.clear_points()

# @impure
func _on_player_detector_body_entered(body: Node2D):
	if body is RkPlayer:
		body.level.earn_experience(value)
		queue_free()
