extends Node2D

# Paths for dead-end areas (adjust these to match your scene structure)
@export var dead_end_areas := ["Choices1", "Choices2", "Choices3", "Choices4"]
# Define music nodes and player path
@export var player := "CharacterBody2D"
var autoloader_music
var background_music
var camera

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
	
	# Make the background visible initially
	var background = $Background
	if background:
		background.visible = true

	# Hide everything initially except AudioStreamPlayer nodes, Background, and ReadyLabel
	for child in get_children():
		if not (child is AudioStreamPlayer or child.name == "ReadyLabel" or child.name == "Background"):
			child.visible = false
	
	# Show only ReadyLabel along with the background
	var ready_label = $ReadyLabel
	if ready_label:
		ready_label.visible = true
		ready_label.text = "Ready?"
	
	# Create camera with initial zoomed out view
	var player_node = find_child("CharacterBody2D", true, false)
	if player_node:
		player_node.global_position = Vector2(105, 327)
		camera = Camera2D.new()
		camera.enabled = true  # Enable for the ready screen
		camera.zoom = Vector2(1, 1)  # Zoomed out view
		camera.limit_left = 100      # Adjust these values
		camera.limit_right = 1152     # to match your maze boundaries
		camera.limit_top = 0       # and prevent seeing grey space
		camera.limit_bottom = 600
		player_node.add_child(camera)
		camera.make_current()
		player_node.add_child(camera)
		camera.make_current()
	
	# Wait for 3 seconds before starting the game
	await get_tree().create_timer(3.0).timeout
	
	# Start the game after the countdown
	start_game()

func start_game():
	# Hide the ReadyLabel
	var ready_label = $ReadyLabel
	if ready_label:
		ready_label.visible = false
	
	# Show everything again except Game2Beat and AudioStreamPlayer nodes
	for child in get_children():
		if not (child is AudioStreamPlayer or child.name == "Game2Beat"):
			child.visible = true
	
	# Now setup the camera for gameplay
	var player_node = find_child("CharacterBody2D", true, false)
	if player_node and camera:
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 7.0
		camera.limit_left = 0
		camera.limit_right = 1600
		camera.limit_top = 250
		camera.limit_bottom = 800
		camera.zoom = Vector2(4.6, 4.6)  # Zoom in for gameplay

	# Connect the ending area signal
	var ending_area = $Ending/Area2D
	if ending_area:
		ending_area.body_entered.connect(_on_ending_entered)
		print("Connected ending area signal")
	else:
		print("WARNING: Ending/Area2D not found!")
	
	# Connect dead-end areas to trigger a transport to Choices scene
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
