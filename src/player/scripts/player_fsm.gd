extends Object
class_name RkStateMachine

var state_nodes := {}

var player_node: RkPlayer
var prev_state_node: RkStateMachineState
var next_state_node: RkStateMachineState
var current_state_node: RkStateMachineState

# _init finds all state nodes in the parent state node and initializes the state machine.
# @impure
func _init(in_player_node: RkPlayer, in_parent_state_node: Node, in_initial_state_node: RkStateMachineState):
	player_node = in_player_node
	current_state_node = in_initial_state_node
	for i in range(0, in_parent_state_node.get_child_count()):
		var state_node: RkStateMachineState = in_parent_state_node.get_child(i)
		state_node.player_node = in_player_node
		state_nodes[state_node.name] = state_node

# _ready initializes the state machine by setting the current state node.
# @impure
func _ready():
	set_state_node(current_state_node)

# set_state_node changes the current state node to the given state node.
# @impure
func set_state_node(state_node: RkStateMachineState):
	# Engine.time_scale = 0.1
	# print("Changing state to: ", state_node.name, " from: ", current_state_node.name)
	next_state_node = state_node
	if current_state_node:
		current_state_node.finish_state()
	prev_state_node = current_state_node
	if state_node == null:
		return
	current_state_node = state_node
	var change_state_node = current_state_node.start_state()
	if change_state_node:
		set_state_node(change_state_node)

# process_state_machine processes the current state node and changes the state if needed.
# @impure
func process_state_machine(delta: float):
	var change_state_node = current_state_node.process_state(delta)
	if change_state_node:
		set_state_node(change_state_node)
