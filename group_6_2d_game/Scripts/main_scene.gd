extends Node2D

func _ready():
	#minigame 1
	var minigame1_collision = get_node("Minigames/Minigame1/Area2D/CollisionShape2D")  # Ensure this path is correct
	if minigame1_collision:
		# Use set_disabled method to disable the CollisionShape2D
		minigame1_collision.set_disabled(GlobalState.daBool)  
		print("Minigame1 Collision disabled:", minigame1_collision.is_disabled())  # Check if it is disabled
	else:
		print("Minigame1 collision not found")
		
	# minigame 2
	var minigame2_collision = get_node("Minigames/Minigame2/Area2D/CollisionShape2D")  # Ensure this path is correct
	if minigame2_collision:
		# Use set_disabled method to disable the CollisionShape2D
		minigame2_collision.set_disabled(GlobalState.daBool2)  
		print("Minigame2 Collision disabled:", minigame2_collision.is_disabled())  # Check if it is disabled
	else:
		print("Minigame2 collision not found")
		
	#minigame 3
	var minigame3_collision = get_node("Minigames/Minigame3/Area2D/CollisionShape2D")  # Ensure this path is correct
	if minigame3_collision:
		# Use set_disabled method to disable the CollisionShape2D
		minigame3_collision.set_disabled(GlobalState.daBool3)  
		print("Minigame3 Collision disabled:", minigame3_collision.is_disabled())  # Check if it is disabled
	else:
		print("Minigame3 collision not found")
