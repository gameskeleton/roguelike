class_name RkUtils

# pick_random returns a random item in the given array using the given rng.
# @impure
static func pick_random(arr: Array, rng: RandomNumberGenerator):
	return arr[rng.randi_range(0, arr.size() - 1)]

# node_global_position returns the given node global position if the node is a Node2D or Control.
# @pure
static func node_global_position(node: Node):
	if node is Node2D or node is Control:
		return node.global_position
	return Vector2.ZERO
