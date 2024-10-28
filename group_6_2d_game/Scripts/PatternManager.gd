extends Node2D

# Constants for round configurations
const ROUND_PATTERNS = [4, 5, 6, 8]  # Number of icons in the pattern for each round
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

# Variables
var current_pattern = []
var player_sequence = []
var current_round = 1
var is_player_turn = false

func _ready():
	# Setup background music
	if BgMusic.playing:
		BgMusic.stop()
		print("Autoload background music stopped.")
	if not background_music.playing:
		background_music.play()
		print("Local background music started.")
	
	setup_buttons()
	start_round(current_round)

func setup_buttons():
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)
		submit_button.disabled = true
	
	for i in range(5):
		var button = player_input.get_child(i)
		if button:
			if button.is_connected("pressed", _on_texture_button_pressed):
				button.pressed.disconnect(_on_texture_button_pressed)
			button.pressed.connect(_on_texture_button_pressed.bind(i))
			button.visible = true
			print("Connected button %d to handle input." % i)

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

func _flash_icon(icon_index):
	var icon_node = pattern_display.get_child(icon_index)
	if icon_node:
		print("Flashing icon %d" % icon_index)
		
		# Store original color and create flash tween
		var original_color = icon_node.modulate
		var flash_tween = create_tween()
		flash_tween.tween_property(icon_node, "modulate", Color(2.0, 2.0, 0.5), 0.2)
		icon_pressed_sound.play()
		
		await get_tree().create_timer(0.3).timeout
		
		# Reset color
		var reset_tween = create_tween()
		reset_tween.tween_property(icon_node, "modulate", original_color, 0.2)
		
		print("Icon flash complete")
	else:
		print("Error: Icon at index %d not found" % icon_index)

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
		
		var button = player_input.get_child(button_index)
		if button:
			# Flash the button
			var original_color = button.modulate
			var flash_tween = create_tween()
			flash_tween.tween_property(button, "modulate", Color(2.0, 2.0, 0.5), 0.1)
			
			# Flash the corresponding pattern icon
			_flash_icon(button_index)
			
			icon_pressed_sound.play()
			
			await get_tree().create_timer(0.1).timeout
			
			# Reset button color
			var reset_tween = create_tween()
			reset_tween.tween_property(button, "modulate", original_color, 0.1)
		
		if player_sequence.size() == current_pattern.size():
			submit_button.disabled = false
			print("Sequence complete - Submit enabled")

func _on_submit_pressed():
	print("Submit pressed - Checking sequence")
	if player_sequence == current_pattern:
		current_round += 1
		if current_round <= ROUND_PATTERNS.size():
			start_round(current_round)
		else:
			print("Victory - All rounds complete!")
	else:
		if current_round == 4:
			start_round(4)
		else:
			current_round = 1
			start_round(current_round)

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
