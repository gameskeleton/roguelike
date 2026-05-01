class_name RkStateMachineState extends Node

var player_node: RkPlayer

# @impure
func start_state() -> RkStateMachineState:
	return null

# @impure
func process_state(_delta: float) -> RkStateMachineState:
	return null

# @impure
func finish_state() -> void:
	pass
