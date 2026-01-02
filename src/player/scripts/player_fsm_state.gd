extends Node
class_name RkStateMachineState

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
