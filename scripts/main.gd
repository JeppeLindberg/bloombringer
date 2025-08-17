extends Node


var _result

# Get all children of the node that belongs to any of the given groups
func get_children_in_groups(node, recursive = false, groups = ['*']):
	_result = []

	if recursive:
		_get_children_in_groups_recursive(node, groups)
		return _result

	for child in node.get_children():
		for group in groups:				
			if (group == '*') or child.is_in_group(group):
				_result.append(child)
				break

	return _result

# Get all children of the node that belongs to any of the given groups
func _get_children_in_groups_recursive(node, groups):
	for child in node.get_children():
		for group in groups:
			if (group == '*') or child.is_in_group(group):
				_result.append(child)
				break

		_get_children_in_groups_recursive(child, groups)

