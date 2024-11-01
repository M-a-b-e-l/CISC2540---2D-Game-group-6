extends Node2D

func _ready():
	var minigame1_collision = get_node("Minigames/Minigame1/Area2D/CollisionShape2D")  # Ensure this path is correct
	if minigame1_collision:
		# Use set_disabled method to disable the CollisionShape2D
		minigame1_collision.set_disabled(GlobalState.daBool)  
		print("Minigame Collision disabled:", minigame1_collision.is_disabled())  # Check if it is disabled
	else:
		print("Minigame collision not found")
