extends RefCounted
class_name RkStateMachine

class StateNodes extends RefCounted:
	var hit: RkStateMachineState
	var fall: RkStateMachineState
	var jump: RkStateMachineState
	var roll: RkStateMachineState
	var skid: RkStateMachineState
	var walk: RkStateMachineState
	var death: RkStateMachineState
	var slide: RkStateMachineState
	var stand: RkStateMachineState
	var attack: RkStateMachineState
	var crouch: RkStateMachineState
	var wall_hang: RkStateMachineState
	var wall_climb: RkStateMachineState
	var wall_slide: RkStateMachineState
	var crouch_walk: RkStateMachineState
	var turn_around: RkStateMachineState
	var bump_into_wall: RkStateMachineState
	var crouch_to_stand: RkStateMachineState
	var stand_to_crouch: RkStateMachineState

	# assert_states checks that all state nodes are set.
	# @pure
	func assert_states():
		assert(hit, "StateNodes: hit is not set")
		assert(fall, "StateNodes: fall is not set")
		assert(jump, "StateNodes: jump is not set")
		assert(roll, "StateNodes: roll is not set")
		assert(skid, "StateNodes: skid is not set")
		assert(walk, "StateNodes: walk is not set")
		assert(death, "StateNodes: death is not set")
		assert(slide, "StateNodes: slide is not set")
		assert(stand, "StateNodes: stand is not set")
		assert(attack, "StateNodes: attack is not set")
		assert(crouch, "StateNodes: crouch is not set")
		assert(wall_hang, "StateNodes: wall_hang is not set")
		assert(wall_climb, "StateNodes: wall_climb is not set")
		assert(wall_slide, "StateNodes: wall_slide is not set")
		assert(crouch_walk, "StateNodes: crouch_walk is not set")
		assert(turn_around, "StateNodes: turn_around is not set")
		assert(bump_into_wall, "StateNodes: bump_into_wall is not set")
		assert(crouch_to_stand, "StateNodes: crouch_to_stand is not set")
		assert(stand_to_crouch, "StateNodes: stand_to_crouch is not set")

var state_nodes := StateNodes.new()

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
		var state_node = in_parent_state_node.get_child(i)
		assert(state_node is RkStateMachineState, "%s must be a RkStateMachineState node" % [state_node.name])
		state_node.player_node = in_player_node
		state_nodes[state_node.name] = state_node
	state_nodes.assert_states()

# _ready initializes the state machine by setting the current state node.
# @impure
func _ready():
	set_state_node(current_state_node)

# set_state_node changes the current state node to the given state node.
# @impure
func set_state_node(state_node: RkStateMachineState):
	print("Changing state to: %s from: %s at frame: %d" % [state_node.name, current_state_node.name, Engine.get_frames_drawn()])
	next_state_node = state_node
	if current_state_node:
		current_state_node.finish_state()
	prev_state_node = current_state_node
	if state_node == null:
		return
	current_state_node = state_node
	var change_state_node = current_state_node.start_state()
	if change_state_node:
		assert(change_state_node is RkStateMachineState, "%s::start_state() must return a RkStateMachineState node" % [current_state_node.name])
		set_state_node(change_state_node)

# process_state_machine processes the current state node and changes the state if needed.
# @impure
func process_state_machine(delta: float):
	var change_state_node = current_state_node.process_state(delta)
	if change_state_node:
		assert(change_state_node is RkStateMachineState, "%s::process_state() must return a RkStateMachineState node" % [current_state_node.name])
		set_state_node(change_state_node)

# is_next_state_node checks if the given state nodes contain the next state node.
# @pure
func is_next_state_node(in_state_nodes: Array[RkStateMachineState]) -> bool:
	for in_state_node in in_state_nodes:
		if in_state_node == next_state_node:
			return true
	return false

# is_prev_state_node checks if the given state nodes contain the previous state node.
# @pure
func is_prev_state_node(in_state_nodes: Array[RkStateMachineState]) -> bool:
	for in_state_node in in_state_nodes:
		if in_state_node == prev_state_node:
			return true
	return false
