extends Node2D

# Paths for dead-end areas (adjust these to match your scene structure)
@export var dead_end_areas := ["Choices1", "Choices2", "Choices3", "Choices4"]
# Define player path
@export var player := "CharacterBody2D"
var autoloader_music
var background_music
var camera
var time_remaining = 300  # 5 minutes in seconds
var timer_label

# Initialize a Timer node at the beginning
@onready var game_timer = Timer.new()  

func _ready() -> void:
	print("MazeGame2 _ready() started")

	# Stop autoloader music immediately
	autoloader_music = get_node("/root/BgMusic")
	if autoloader_music:
		autoloader_music.stop()
		print("Stopped autoloader music")

	# Start background music
	background_music = $BackGroundMusic
	if background_music:
		background_music.play()
		print("Started background music")

	# Make the background visible initially
	var background = $Background
	if background:
		background.visible = true

	# Hide all nodes except AudioStreamPlayer nodes, Background, and ReadyLabel
	for child in get_children():
		if not (child is AudioStreamPlayer or child.name == "ReadyLabel" or child.name == "Background" or child.name == "InstructionLabel"):
			child.visible = false
	
	# Show only ReadyLabel
	var ready_label = $ReadyLabel
	if ready_label:
		ready_label.visible = true
		ready_label.text = "Ready?"
		
	# Hide Game Over container initially
	var game_over_container = $GameOverContainer
	if game_over_container:
		game_over_container.visible = false

	# Hide Game2Beat label initially
	var game2beat = $Game2Beat
	if game2beat:
		game2beat.visible = false  # Hide Game2Beat at the start

	# Create camera with initial settings
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

	# Wait for 3 seconds before starting the game
	await get_tree().create_timer(3.0).timeout
	
				# Show InstructionLabel for 5 seconds after ReadyLabel
	var instruction_label = $InstructionLabel
	if instruction_label:
		instruction_label.visible = false  # Initially hidden
		instruction_label.visible = true  # Show the InstructionLabel
	
	if ready_label:
		ready_label.visible = false
	
	await get_tree().create_timer(5.0).timeout  # Wait for 5 seconds

	# Start the game after the countdown
	start_game()

func start_game():
	
	# Hide the InstructionLabel at the start of the game
	var instruction_label = $InstructionLabel
	if instruction_label:
		instruction_label.visible = false
		instruction_label.z_index = -1  # Set z-index to -1
		
		# Hide the ReadyLabel
	var ready_label = $ReadyLabel
	if ready_label:
		ready_label.visible = false
	
	# Hide Game Over container and label during gameplay
	var game_over_container = $GameOverContainer
	if game_over_container:
		game_over_container.visible = false
	
	# Hide Game2Beat label initially
	var game2beat = $Game2Beat
	if game2beat:
		game2beat.visible = false  # Hide Game2Beat at the start
	
	var game_over_label = $GameOverContainer/DeadEndLabel  # Get the GameOverLabel node
	if game_over_label:
		game_over_label.visible = false
	
	# Show everything again except GameOverContainer and AudioStreamPlayer nodes
	for child in get_children():
		if not (child is AudioStreamPlayer or child.name == "GameOverContainer" or child.name == "DeadEndLabel"):
			child.visible = true
	
	# Set up the camera for gameplay
	var player_node = find_child("CharacterBody2D", true, false)
	if player_node and camera:
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 7.0
		camera.limit_left = 0
		camera.limit_right = 1600
		camera.limit_top = 0
		camera.limit_bottom = 600
		camera.zoom = Vector2(4.6, 4.6)  # Zoom in for gameplay

	# Initialize the timer and start the countdown
	timer_label = $Timer/TimerLabel
	var custom_font = load("res://Fonts/Emulogic-zrEw.ttf")
	
	if timer_label and custom_font:
		timer_label.add_theme_font_override("font", custom_font)
	else:
		print("Failed to load either TimerLabel or the custom font.")
	
	# Setup the timer
	add_child(game_timer)  # Add timer to scene
	game_timer.wait_time = 1.0
	game_timer.timeout.connect(_on_timer_tick)
	game_timer.start()
	
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
		# Hide everything except AudioStreamPlayer nodes
		for child in get_children():
			if not (child is AudioStreamPlayer) and has_method("set_visible") and (child is Node2D):
				child.visible = false

		# Explicitly hide ReadyLabel if it exists
		var ready_label = $ReadyLabel  # Ensure this path is correct for your ReadyLabel
		if ready_label:
			ready_label.visible = false  # Hide the ReadyLabel explicitly

		# Reset camera to Game Over view if necessary
		if camera:
			camera.zoom = Vector2(1, 1)  # Zoomed out view
			camera.limit_left = 100      # Adjust these values
			camera.limit_right = 1152     # to match your maze boundaries
			camera.limit_top = 0       # and prevent seeing grey space
			camera.limit_bottom = 600
			camera.make_current()  # Ensure this camera is the current one

		# Ensure background is visible
		var background = $Background  # Adjust this path to your background node's path
		if background:
			background.visible = true

		# Show Game2Beat label and set its z-index back to 1
		var game2beat = $Game2Beat
		if game2beat:
			game2beat.visible = true
			game2beat.z_index = 1  # Set z-index back to 1

		# Wait for 2 seconds then change scene
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Scenes/Minigame3/MiniGame3.tscn")

# Called when the player enters a dead-end area
func _on_dead_end_entered(body: Node2D) -> void:
	print("Dead end area entered by: ", body)
	var player_node = find_child(player, true, false)
	if body == player_node:
		print("Player entered dead-end area! Showing GameOver options...")

		# Hide everything except background and GameOverContainer
		for child in get_children():
			if child is Node2D or child is Control:
				if not (child is AudioStreamPlayer or child.name == "Background" or child.name == "GameOverContainer"):
					child.visible = false

		# Show GameOverContainer and its buttons
		var game_over_container = $GameOverContainer
		if game_over_container:
			game_over_container.visible = true
			
			# Show retry and main menu buttons
			var retry_button = game_over_container.get_node("RetryButton")
			var main_menu_button = game_over_container.get_node("MainMenuButton")
			var game_over_label = game_over_container.get_node("DeadEndLabel")
			var time_up_label = game_over_container.get_node("TimeUpLabel")

			retry_button.visible = true
			main_menu_button.visible = true
			game_over_label.visible = true
			time_up_label.visible = false
			
			# Connect button signals if not already connected
			if !retry_button.is_connected("pressed", Callable(self, "_on_retry_pressed")):
				retry_button.pressed.connect(Callable(self, "_on_retry_pressed"))
			if !main_menu_button.is_connected("pressed", Callable(self, "_on_main_menu_pressed")):
				main_menu_button.pressed.connect(Callable(self, "_on_main_menu_pressed"))

		# Reset camera settings to show everything
		if camera:
			camera.zoom = Vector2(1, 1)  # Zoomed out view
			camera.limit_left = 100      # Adjust these values
			camera.limit_right = 1152     # to match your maze boundaries
			camera.limit_top = 0       # and prevent seeing grey space
			camera.limit_bottom = 600
			camera.make_current()  # Ensure this camera is the current one

# Function to reset the minigame
func _on_retry_pressed() -> void:
	print("Retrying minigame...")
	get_tree().change_scene_to_file("res://Scenes/MazeGame2.tscn")  # Reload the same scene

# Function to go to the main menu
func _on_main_menu_pressed() -> void:
	print("Going to Main Menu...")

	# Play autoload music immediately
	if autoloader_music:
		autoloader_music.play()
		print("Playing autoloader music")

	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")  # Change to main menu scene

# Countdown timer tick function
func _on_timer_tick():
	time_remaining -= 1

	if time_remaining < 0:
		time_remaining = 0  # Prevent negative values
	# Update the timer label
	var minutes = int(time_remaining / 60)
	var seconds = time_remaining % 60    # Modulus to get remaining seconds
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Change color to red in final 30 seconds
	if time_remaining <= 30:
		timer_label.modulate = Color(1, 0, 0)  # Set color to red
	
	# End game if timer reaches zero
	if time_remaining <= 0:
		_trigger_game_over()

func _trigger_game_over():
	# Stop the timer
	if game_timer:
		game_timer.stop()
	
		# Hide everything except background and GameOverContainer
		for child in get_children():
			if child is Node2D or child is Control:
				if not (child is AudioStreamPlayer or child.name == "Background" or child.name == "GameOverContainer"):
					child.visible = false

		# Show GameOverContainer and its buttons
		var game_over_container = $GameOverContainer
		if game_over_container:
			game_over_container.visible = true
			
			# Show retry and main menu buttons
			var retry_button = game_over_container.get_node("RetryButton")
			var main_menu_button = game_over_container.get_node("MainMenuButton")
			var game_over_label = game_over_container.get_node("DeadEndLabel")
			var time_up_label = game_over_container.get_node("TimeUpLabel")

			retry_button.visible = true
			main_menu_button.visible = true
			game_over_label.visible = false
			time_up_label.visible = true
			
			# Connect button signals if not already connected
			if !retry_button.is_connected("pressed", Callable(self, "_on_retry_pressed")):
				retry_button.pressed.connect(Callable(self, "_on_retry_pressed"))
			if !main_menu_button.is_connected("pressed", Callable(self, "_on_main_menu_pressed")):
				main_menu_button.pressed.connect(Callable(self, "_on_main_menu_pressed"))

		# Reset camera settings to show everything
		if camera:
			camera.zoom = Vector2(1, 1)  # Zoomed out view
			camera.limit_left = 100      # Adjust these values
			camera.limit_right = 1152     # to match your maze boundaries
			camera.limit_top = 0       # and prevent seeing grey space
			camera.limit_bottom = 600
			camera.make_current()  # Ensure this camera is the current one
