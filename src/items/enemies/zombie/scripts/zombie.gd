extends CharacterBody2D

const MAX_SPEED := 50.0
const ACCELERATION := 100.0

const GRAVITY_MAX_SPEED := 800.0
const GRAVITY_ACCELERATION := 850.0

var direction := 1.0

func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, MAX_SPEED * direction, delta * ACCELERATION)
	velocity.y = move_toward(velocity.y, GRAVITY_MAX_SPEED, delta * GRAVITY_ACCELERATION)
	move_and_slide()
	if is_on_wall():
		direction *= -1.0

func _on_life_points_damage_taken(_damage: float, _source: Node, _instigator: Node) -> void:
	queue_free()

func _on_player_detector_body_entered(body: Node2D) -> void:
	var life_points_system := RkLifePointsSystem.find_system_node(body)
	if life_points_system:
		life_points_system.take_damage(3.0, RkLifePointsSystem.DmgType.physical)
