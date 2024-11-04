extends Node2D

# Paths for dead-end areas
@export var dead_end_areas := ["Choices1", "Choices2", "Choices3", "Choices4"]
@export var player := "CharacterBody2D"

# Node references
var player_node: Node2D
var autoloader_music
var background_music
var camera
var time_remaining = 180  # 3 minutes in seconds
var timer_label
var ready_label  # Add this declaration

# Initialize nodes
@onready var game_timer = Timer.new() 
@onready var spotlight = $CanvasLayer/TextureRect

func _ready() -> void:
	print("MazeGame2 _ready() started")

	# Find and set up player node first
	player_node = find_child("CharacterBody2D", true, false)
	if player_node:
		player_node.global_position = Vector2(105, 327)
		# Set up camera
		camera = Camera2D.new()
		player_node.add_child(camera)
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 7.0
		camera.zoom = Vector2(1, 1)
		camera.limit_left = 0
		camera.limit_right = 1600
		camera.limit_top = 0
		camera.limit_bottom = 600
		camera.make_current()
		camera.enabled = true

	# Stop autoloader music
	autoloader_music = get_node("/root/BgMusic")
	if autoloader_music:
		autoloader_music.stop()
		print("Stopped autoloader music")

	# Start background music
	background_music = $BackGroundMusic
	if background_music:
		background_music.play()
		print("Started background music")

	# Make background visible initially
	var background = $Background
	if background:
		background.visible = true

	# Get and set up ReadyLabel first
	ready_label = $ReadyLabel

	# Hide all nodes except specific ones, but handle CanvasLayer separately
	for child in get_children():
		if child is CanvasLayer:
			child.visible = true
			continue
		if not (child is AudioStreamPlayer or child == ready_label
				or child.name == "Background" or child.name == "InstructionLabel"):
			child.visible = false

	# Show ReadyLabel
	if ready_label:
		ready_label.visible = true
		ready_label.text = "Ready?"

	# Hide specific containers
	if $GameOverContainer:
		$GameOverContainer.visible = false
	if $Game2Beat:
		$Game2Beat.visible = false

	# Set up spotlight
	var canvas_layer = $CanvasLayer
	if canvas_layer:
		spotlight = canvas_layer.get_node("TextureRect")
		if spotlight and player_node:
			spotlight.visible = true
			spotlight.z_index = 100
			spotlight.set("player_path", spotlight.get_path_to(player_node))

	# Start game sequence
	await get_tree().create_timer(3.0).timeout

	# Show instruction label
	var instruction_label = $InstructionLabel
	if instruction_label:
		instruction_label.visible = true
	if ready_label:
		ready_label.visible = false

	await get_tree().create_timer(5.0).timeout
	start_game()

func start_game():

	# Hide instruction and ready labels
	if $InstructionLabel:
		$InstructionLabel.visible = false
		$InstructionLabel.z_index = -1
	if $ReadyLabel:
		$ReadyLabel.visible = false

	# Hide game over elements
	if $GameOverContainer:
		$GameOverContainer.visible = false
	if $Game2Beat:
		$Game2Beat.visible = false
	if $GameOverContainer/DeadEndLabel:
		$GameOverContainer/DeadEndLabel.visible = false

	for child in get_children():
		if not (child is AudioStreamPlayer or child.name == "GameOverContainer" 
				or child.name == "DeadEndLabel"):
			child.visible = true
	
	# Ensure CanvasLayer and TextureRect stay visible
		if child is CanvasLayer:
			child.visible = true
			if spotlight:
				spotlight.visible = true
			else:
				print("Warning: TextureRect not found within CanvasLayer")

	# Set up gameplay camera
	if player_node and camera:
		camera.zoom = Vector2(4.6, 4.6)
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 7.0
		camera.limit_left = 0
		camera.limit_right = 1600
		camera.limit_top = 0
		camera.limit_bottom = 600
		camera.make_current()

	# Set up timer
	timer_label = $Timer/TimerLabel
	var custom_font = load("res://Fonts/Emulogic-zrEw.ttf")
	if timer_label and custom_font:
		timer_label.add_theme_font_override("font", custom_font)
	
	# Initialize game timer
	add_child(game_timer)
	game_timer.wait_time = 1.0
	game_timer.timeout.connect(_on_timer_tick)
	game_timer.start()

	# Connect area signals
	var ending_area = $Ending/Area2D
	if ending_area:
		if !ending_area.body_entered.is_connected(_on_ending_entered):
			ending_area.body_entered.connect(_on_ending_entered)
			print("Connected ending area signal")

	# Connect dead-end areas
	for area_name in dead_end_areas:
		var choice_area = get_node_or_null(area_name + "/Area2D")
		if choice_area and !choice_area.body_entered.is_connected(_on_dead_end_entered):
			choice_area.body_entered.connect(_on_dead_end_entered)
			print("Connected signal for: ", area_name)

func _on_ending_entered(body: Node2D) -> void:
	if body == player_node:
		# Hide everything except AudioStreamPlayer nodes
		for child in get_children():
			if not (child is AudioStreamPlayer) and has_method("set_visible") and (child is Node2D):
				child.visible = false

		# Explicitly hide ReadyLabel if it exists
		if ready_label:
			ready_label.visible = false

		# Reset camera to Game Over view
		if camera:
			camera.zoom = Vector2(1, 1)
			camera.limit_left = 100
			camera.limit_right = 1152
			camera.limit_top = 0
			camera.limit_bottom = 600
			camera.make_current()

		# Ensure background is visible
		var background = $Background
		if background:
			background.visible = true

		# Show Game2Beat label and set its z-index
		var game2beat = $Game2Beat
		if game2beat:
			game2beat.visible = true
			game2beat.z_index = 1

		# Wait then change scene
		await get_tree().create_timer(3.0).timeout
		GlobalState.daBool2 = true

		# Handle music transition
		if background_music.playing:
			background_music.stop()
		if autoloader_music and not autoloader_music.playing:
			autoloader_music.play()
		
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
		GlobalState.player_position = Vector2(613, 490)

func _on_dead_end_entered(body: Node2D) -> void:
	print("Dead end area entered by: ", body)
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
			if !retry_button.pressed.is_connected(_on_retry_pressed):
				retry_button.pressed.connect(_on_retry_pressed)
			if !main_menu_button.pressed.is_connected(_on_main_menu_pressed):
				main_menu_button.pressed.connect(_on_main_menu_pressed)

		# Reset camera settings
		if camera:
			camera.zoom = Vector2(1, 1)
			camera.limit_left = 100
			camera.limit_right = 1152
			camera.limit_top = 0
			camera.limit_bottom = 600
			camera.make_current()

func _on_retry_pressed() -> void:
	print("Retrying minigame...")
	get_tree().change_scene_to_file("res://Scenes/MazeGame2.tscn")

func _on_main_menu_pressed() -> void:
	print("Going to Main Map...")
	if autoloader_music:
		autoloader_music.play()
		print("Playing autoloader music")
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	GlobalState.player_position = Vector2(550, 360)

func _on_timer_tick():
	time_remaining -= 1
	if time_remaining < 0:
		time_remaining = 0

	# Update timer label
	var minutes = int(time_remaining / 60)
	var seconds = time_remaining % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Change color in final 30 seconds
	if time_remaining <= 30:
		timer_label.modulate = Color(1, 0, 0)
	
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
		if !retry_button.pressed.is_connected(_on_retry_pressed):
			retry_button.pressed.connect(_on_retry_pressed)
		if !main_menu_button.pressed.is_connected(_on_main_menu_pressed):
			main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Reset camera settings
	if camera:
		camera.zoom = Vector2(1, 1)
		camera.limit_left = 100
		camera.limit_right = 1152
		camera.limit_top = 0
		camera.limit_bottom = 600
		camera.make_current()
