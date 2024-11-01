extends Node2D

# Paths for dead-end areas (adjust these to match your scene structure)
@export var dead_end_areas := ["Choices1", "Choices2", "Choices3", "Choices4"]
# Define music nodes and player path
@export var player := "CharacterBody2D"
var autoloader_music
var background_music

func _ready():
	print("MazeGame2 _ready() started")
	
	# Stop autoloader music immediately
	autoloader_music = get_node("/root/BgMusic")
	if autoloader_music:
		autoloader_music.stop()
		print("Stopped autoloader music")
	
	background_music = $BackGroundMusic
	if background_music:
		background_music.play()
		print("Started background music")
	
	# Hide everything initially except AudioStreamPlayer nodes and ReadyLabel
	for child in get_children():
		if not child is AudioStreamPlayer and child.name != "ReadyLabel":
			child.visible = false
	
	# Show only ReadyLabel
	var ready_label = $ReadyLabel
	if ready_label:
		ready_label.visible = true
	
	# Wait for 2 seconds then start game
	await get_tree().create_timer(2.0).timeout
	start_game()

func start_game():
	# Show everything again except Game2Beat and AudioStreamPlayer nodes
	for child in get_children():
		if not child is AudioStreamPlayer and child.name != "Game2Beat":
			child.visible = true
	
	# Get the character body reference and set its position
	var player_node = find_child("CharacterBody2D", true, false)
	print("Looking for player node...")
	
	if player_node:
		print("Found player node at: ", player_node.global_position)
		player_node.global_position = Vector2(105, 327)
		
		# Set up camera now that ready label is gone
		var camera = Camera2D.new()
		player_node.add_child(camera)
		camera.make_current()
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 7.0
		camera.limit_left = 0
		camera.limit_right = 1600
		camera.limit_top = 250
		camera.limit_bottom = 800
		camera.zoom = Vector2(4.6, 4.6)
		
		# Connect the ending area signal
		var ending_area = $Ending/Area2D
		if ending_area:
			ending_area.body_entered.connect(_on_ending_entered)
			print("Connected ending area signal")
		else:
			print("WARNING: Ending/Area2D not found!")
		
		print("Set player position to: ", player_node.global_position)
		await get_tree().create_timer(0.1).timeout
		print("Player position after delay: ", player_node.global_position)
	else:
		print("ERROR: Player node not found!")
	
	# Connect the dead-end areas to trigger a transport to Choices scene
	print("Searching for dead-end areas...")
	for area_name in dead_end_areas:
		var choice_area = get_node_or_null(area_name + "/Area2D")
		if choice_area:
			print("Found area: ", area_name)
			if !choice_area.body_entered.is_connected(Callable(self, "_on_dead_end_entered")):
				choice_area.body_entered.connect(_on_dead_end_entered)
				print("Connected signal for: ", area_name)
		else:
			print("Warning: Dead-end area not found:", area_name)

# Called when the player enters the ending area
func _on_ending_entered(body: Node2D) -> void:
	var player_node = find_child(player, true, false)
	if body == player_node:
		# Hide everything except Game2Beat and AudioStreamPlayer nodes
		for child in get_children():
			if not child is AudioStreamPlayer and child.name != "Game2Beat":
				child.visible = false
		
		# Show Game2Beat label
		var game2beat = $Game2Beat
		if game2beat:
			game2beat.visible = true
		
		# Wait for 2 seconds then change scene
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/MiniGame3.tscn")

# Called when the player enters a dead-end area
func _on_dead_end_entered(body: Node2D) -> void:
	print("Dead end area entered by: ", body)
	var player_node = find_child(player, true, false)
	if body == player_node:
		print("Player entered dead-end area! Transporting to choices scene...")
		transport_to_choices_scene()

# Function to transport to the choices scene
func transport_to_choices_scene() -> void:
	# Store the position for other scenes before changing
	GlobalState.player_position = Vector2(298, 307)
	print("Set GlobalState.player_position to: ", GlobalState.player_position)
	# Change to the Choices scene
	get_tree().change_scene_to_file("res://Scenes/Choices.tscn")
