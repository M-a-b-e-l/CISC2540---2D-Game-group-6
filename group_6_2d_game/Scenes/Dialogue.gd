extends Control

@export var interaction_duration: float = 4.0  # Time duration for dialogue display

# Nodes
@onready var player = get_node("../CharacterBody2D")
@onready var aliens_container = get_node("../Aliens")
@onready var bubble_sprites_container = self  # DialogueBox is the current node

# Variables
var bubble_sprites: Array = []
var aliens: Array = []

func _ready() -> void:
	# Initialize bubble sprites and hide them
	for i in [1, 2, 3, 4, 10, 11]:
		var bubble_sprite = bubble_sprites_container.get_node_or_null("BubbleSprite" + str(i))
		if bubble_sprite:
			bubble_sprite.visible = false
			bubble_sprites.append(bubble_sprite)
			print("BubbleSprite" + str(i) + " initialized and hidden.")
		else:
			print("WARNING: BubbleSprite" + str(i) + " not found!")

	# Collect all relevant alien nodes (only those with dialogue)
	if aliens_container:
		for i in [1, 2, 3, 4, 10, 11]:
			var alien = aliens_container.get_node_or_null("Alien" + str(i))
			if alien:
				aliens.append(alien)
				print("Alien found: " + alien.name)
			else:
				print("WARNING: Alien" + str(i) + " not found!")
	else:
		print("ERROR: Aliens container not found!")

	if not player:
		print("ERROR: Player node not found!")
	elif aliens.size() == 0:
		print("ERROR: No relevant aliens with dialogue found!")

func _process(_delta: float) -> void:
	if not player or aliens.size() == 0:
		return

	# Check interactions between player and relevant aliens
	for i in range(aliens.size()):
		var alien = aliens[i]
		var static_body_node = alien.get_child(0)  # Assuming StaticBody2D is the first child under each Alien node

		if static_body_node and static_body_node is StaticBody2D:
			var alien_collision_shape = static_body_node.get_node_or_null("CollisionShape2D")
			if alien_collision_shape:
				var distance = alien_collision_shape.global_position.distance_to(player.global_position)
				print("Distance to " + alien.name + ": " + str(distance))

				if distance < 20:  # Adjusted distance for close proximity
					if i < bubble_sprites.size() and not bubble_sprites[i].visible:
						print("Showing dialogue for " + alien.name)
						show_dialogue(i)
						await hide_dialogue_after_delay(i, interaction_duration)
					elif distance >= 20 and bubble_sprites[i].visible:
						print("Hiding dialogue for " + alien.name)
						hide_dialogue(i)
			else:
				print("WARNING: " + alien.name + " does not have a valid CollisionShape2D.")
		else:
			print("WARNING: " + alien.name + " does not have a valid StaticBody2D.")

func show_dialogue(index: int) -> void:
	if index < bubble_sprites.size():
		bubble_sprites[index].visible = true
		print("Dialogue shown for Alien " + str(index + 1))

func hide_dialogue(index: int) -> void:
	if index < bubble_sprites.size():
		bubble_sprites[index].visible = false
		print("Dialogue hidden for Alien " + str(index + 1))

func hide_dialogue_after_delay(index: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	hide_dialogue(index)
