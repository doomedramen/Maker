extends Node

static func node_exists(node):
    if node == null:
      return false

    var ref = weakref(node).get_ref()

    if ref == null:
      return false

    if ref.is_queued_for_deletion():
      return false

    return true
	
static func is_parent_of(node, child):
	return child.get_owner() == node
	
static func remove_children(node):
    for child in node.get_children():
      remove_child_by_node(node, child)

static func remove_child_by_node(node, child, force = true):
	if force:
		call('_remove_child_by_node', node, child, force)
	else:
		call_deferred('_remove_child_by_node', node, child, force)
	
static func _remove_child_by_node(node, child, force):
	if node_exists(node) and node_exists(child) and is_parent_of(node, child):
		node.remove_child(child)
	
		if force:
			# If we force the deletion we need to be sure that the node is not blocked
			# That is why we use 'queue_free'
			child.call_deferred('free')
		else:
			child.free()
	elif node_exists(child):
		if force:
			# If we force the deletion we need to be sure that the node is not blocked
			# That is why we use 'queue_free'
			child.call_deferred('free')
		else:
			child.free()
	else:
		print('You are trying to remove a null child')
		
static func process_node_name(name):
	return name.replace('@','')