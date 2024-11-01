extends Node2D

# Paths for dead-end areas (adjust these to match your scene structure)
@export var dead_end_areas := ["Choices1", "Choices2", "Choices3", "Choices4"]

# Define music nodes and player path
@export var player := "CharacterBody2D"
var autoloader_music
var background_music

# Called when the node enters the scene tree for the first time
func _ready():
	# Get the character body reference and set its position
	var player_node = find_child("CharacterBody2D", true, false)
	if player_node:
		player_node.global_position = Vector2(158, 503)
	
	# Stop autoloader music and play this game's background music
	autoloader_music = get_node("/root/BgMusic")  # Using the correct autoload name
	if autoloader_music:
		autoloader_music.stop()
	
	background_music = $BackGroundMusic
	if background_music:
		background_music.play()
	
	# Connect the dead-end areas to trigger a transport to Choices scene
	for area_name in dead_end_areas:
		# Using find_child() instead of has_node() for more reliable child node finding
		var area = find_child(area_name, true, false) as Area2D
		if area:
			# Connect the signal
			if !area.body_entered.is_connected(Callable(self, "_on_dead_end_entered")):
				area.body_entered.connect(_on_dead_end_entered)
		else:
			print("Warning: Dead-end area not found:", area_name)

# Called when the player enters a dead-end area
func _on_dead_end_entered(body: Node2D) -> void:
	var player_node = find_child(player, true, false)
	if body == player_node:
		print("Player entered dead-end area! Transporting to choices scene...")
		transport_to_choices_scene()

# Function to transport to the choices scene
func transport_to_choices_scene() -> void:
	# Store the position for other scenes before changing
	GlobalState.player_position = Vector2(298, 307)
	# Change to the Choices scene
	get_tree().change_scene_to_file("res://Scenes/Choices.tscn")
