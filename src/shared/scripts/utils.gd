class_name RkUtils

# clear_node_children removes all children in the given node.
# @impure
static func clear_node_children(node: Node):
	while node.get_child_count() > 0:
		node.remove_child(node.get_child(0))
