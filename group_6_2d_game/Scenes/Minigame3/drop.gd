extends Marker2D



func select():
	for child in get_tree().get_nodes_in_group("droppable"):
		child.deselect()
	modulate = Color.AQUAMARINE


func deselect():
	modulate = Color.ANTIQUE_WHITE
