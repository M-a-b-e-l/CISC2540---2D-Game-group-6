extends Node2D

const ROUND_PATTERNS = [4, 5, 6]  # Changed to 3 rounds with 4, 5, 6 icons
const MAX_ICON_REPEAT = 2  # Max times an icon can repeat consecutively

# Nodes
@onready var pattern_display = get_node("PatternDisplay")
@onready var player_input = get_node("PlayerInput")
@onready var timer = get_node("Timer")
@onready var submit_button = get_node("PlayerInput/SubmitButton")
@onready var round_label = get_node("RoundNumber")
@onready var background_music = get_node("BackgroundMusic")
@onready var icon_pressed_sound = get_node("IconPressedSound")
@onready var ready_label = get_node("ReadyLabel")
@onready var minigame_title = get_node("MinigameTitle")
@onready var game_over_container = get_node("GameOverContainer")
@onready var retry_button = get_node("GameOverContainer/RetryButton")
@onready var main_menu_button = get_node("GameOverContainer/MainMenuButton")
@onready var game_over_label = get_node("GameOverContainer/GameOverLabel")
@onready var result_label = get_node("GameOverContainer/ResultLabel")
@onready var game1_beat = get_node("Game1Beat")

# Variables
var current_pattern = []
var player_sequence = []
var current_round = 1
var is_player_turn = false

func _ready():
	# Create unique materials for each icon
	for i in range(5):
		var icon = pattern_display.get_child(i)
		if icon and icon.material:
			icon.material = icon.material.duplicate()
			icon.material.set_shader_parameter("flash_intensity", 0.0)
	
	# Setup background music
	if BgMusic.playing:
		BgMusic.stop()
		print("Autoload background music stopped.")
	if not background_music.playing:
		background_music.play()
		print("Local background music started.")
	
	setup_buttons()
	hide_game_over_screen()
	game1_beat.visible = false
	start_round(current_round)

func setup_buttons():
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)
		submit_button.disabled = true
	
	# Setup game over screen buttons
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Setup pattern buttons
	for i in range(5):
		var button = player_input.get_child(i)
		if button:
			if button.is_connected("pressed", _on_texture_button_pressed):
				button.pressed.disconnect(_on_texture_button_pressed)
			button.pressed.connect(_on_texture_button_pressed.bind(i))
			button.visible = true
			print("Connected button %d to handle input." % i)

func _flash_icon(icon_index):
	var icon_node = pattern_display.get_child(icon_index)
	if icon_node and icon_node.material:
		print("Flashing icon %d" % icon_index)
		
		# Flash the specific icon
		icon_node.material.set_shader_parameter("flash_intensity", 1.0)
		icon_pressed_sound.play()
		
		await get_tree().create_timer(0.3).timeout
		
		# Reset only this icon's flash
		icon_node.material.set_shader_parameter("flash_intensity", 0.0)
		print("Icon flash complete")
	else:
		print("Error: Icon %d not found or has no material" % icon_index)

func show_pattern(pattern):
	print("Showing pattern: ", pattern)
	for i in range(pattern.size()):
		await get_tree().create_timer(0.8).timeout
		await _flash_icon(pattern[i])
	print("Pattern display complete")

func _on_texture_button_pressed(button_index):
	if is_player_turn:
		print("Button %d pressed" % button_index)
		player_sequence.append(button_index)
		
		# Flash the corresponding pattern icon
		_flash_icon(button_index)
		
		if player_sequence.size() == current_pattern.size():
			submit_button.disabled = false
			print("Sequence complete - Submit enabled")

func show_game_over_screen():
	pattern_display.visible = false
	player_input.visible = false
	submit_button.visible = false
	round_label.visible = false
	minigame_title.visible = false
	game_over_container.visible = true
	game_over_label.text = "GAME OVER!"
	result_label.text = "YOU REACHED ROUND: " + str(current_round)
	GlobalState.daBool = false

func hide_game_over_screen():
	game_over_container.visible = false
	pattern_display.visible = true
	player_input.visible = true
	submit_button.visible = true
	round_label.visible = true
	minigame_title.visible = true

func show_victory_screen():
	# Hide all game elements
	pattern_display.visible = false
	player_input.visible = false
	submit_button.visible = false
	round_label.visible = false
	minigame_title.visible = false
	game_over_container.visible = false
	GlobalState.daBool = true
	
	# Show victory label
	game1_beat.text = "GAME 1 COMPLETE! MOVING ON..."
	game1_beat.visible = true
	
	# Wait 3 seconds then transition to maze game
	await get_tree().create_timer(3.0).timeout
	
	# Stop minigame music and start main music
	if background_music.playing:
		background_music.stop()
	if not BgMusic.playing:
		BgMusic.play()
	
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")
	GlobalState.player_position = Vector2(140, 230)

func _on_retry_pressed():
	hide_game_over_screen()
	current_round = 1
	start_round(current_round)

func _on_main_menu_pressed():
	if background_music.playing:
		background_music.stop()
	if not BgMusic.playing:
		BgMusic.play()
	get_tree().change_scene_to_file("res://scenes/main_scene.tscn")

func start_round(round_num):
	print("Starting round %d" % round_num)
	submit_button.disabled = true
	await show_ready_text()
	current_pattern = generate_pattern(round_num)
	player_sequence.clear()
	is_player_turn = false
	update_round_label()
	await show_pattern(current_pattern)
	start_player_turn()

func show_ready_text():
	print("Showing 'Ready?' text and hiding other nodes.")
	pattern_display.visible = false
	player_input.visible = false
	submit_button.visible = false
	ready_label.visible = true
	ready_label.text = "Ready?"
	
	await get_tree().create_timer(3.0).timeout
	
	ready_label.visible = false
	pattern_display.visible = true
	player_input.visible = true
	submit_button.visible = true
	print("Ready text hidden, nodes restored.")

func _on_submit_pressed():
	print("Submit pressed - Checking sequence")
	print("Player sequence: ", player_sequence)
	print("Current pattern: ", current_pattern)
	
	if player_sequence == current_pattern:
		# Player succeeded
		current_round += 1
		if current_round <= ROUND_PATTERNS.size():
			start_round(current_round)
		else:
			print("Victory - All rounds complete!")
			show_victory_screen()
	else:
		# Player failed - always reset to beginning
		print("Failed - Resetting to beginning")
		show_game_over_screen()

func update_round_label():
	round_label.text = "Round: %d" % current_round
	print("Updated round label to: Round %d" % current_round)

func generate_pattern(round_num):
	var pattern_length = ROUND_PATTERNS[round_num - 1]
	var pattern = []
	for i in range(pattern_length):
		var icon
		while true:
			icon = randi() % 5
			if i < MAX_ICON_REPEAT or icon != pattern[i - 1] or icon != pattern[i - 2]:
				break
		pattern.append(icon)
	return pattern

func start_player_turn():
	is_player_turn = true
	print("Player's turn started. Waiting for input.")
