extends Node2D

func _ready():
	print("GlobalState check: daBool =", GlobalState.daBool, ", daBool2 =", GlobalState.daBool2, ", daBool3 =", GlobalState.daBool3)

	# Minigame 1 portal activation
	var minigame1_collision = get_node("Minigames/Minigame1/Area2D/CollisionShape2D")
	if minigame1_collision:
		minigame1_collision.set_disabled(GlobalState.daBool)
		print("Minigame1 Collision disabled:", minigame1_collision.is_disabled())
	else:
		print("Minigame1 collision not found")

	# Minigame 2 portal activation
	var minigame2_collision = get_node("Minigames/Minigame2/Area2D/CollisionShape2D")
	if minigame2_collision:
		minigame2_collision.set_disabled(GlobalState.daBool2)
		print("Minigame2 Collision disabled:", minigame2_collision.is_disabled())
	else:
		print("Minigame2 collision not found")

	# Minigame 3 portal activation
	var minigame3_collision = get_node("Minigames/Minigame3/Area2D/CollisionShape2D")
	if minigame3_collision:
		minigame3_collision.set_disabled(GlobalState.daBool3)
		print("Minigame3 Collision disabled:", minigame3_collision.is_disabled())
	else:
		print("Minigame3 collision not found")
