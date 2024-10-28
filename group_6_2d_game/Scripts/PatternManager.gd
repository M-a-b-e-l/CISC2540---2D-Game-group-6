extends Node2D

# Constants for round configurations
const ROUND_PATTERNS = [4, 5, 6, 8]  # Number of icons in the pattern for each round
const MAX_ICON_REPEAT = 2  # Max times an icon can repeat consecutively

# Nodes
@onready var pattern_display = $PatternDisplay
@onready var player_input = $PlayerInput
@onready var timer = $Timer
@onready var submit_button = $PlayerInput/SubmitButton
@onready var round_label = $RoundNumber  # Reference to the round label

# Variables
var current_pattern = []
var player_sequence = []
var current_round = 1
var is_player_turn = false

func _ready():
	start_round(current_round)
	submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))
	
	# Connect texture buttons to handle player input
	for i in range(5):
		var button = player_input.get_child(i)  # Assuming PlayerInput has 5 TextureButtons as children
		button.connect("pressed", Callable(self, "_on_texture_button_pressed").bind(i))
	
	update_round_label()  # Set the initial round label text

func start_round(round_num):
	current_pattern = generate_pattern(round_num)
	player_sequence.clear()
	is_player_turn = false
	update_round_label()  # Update the label when a new round starts
	show_pattern(current_pattern)

func update_round_label():
	round_label.text = "Round: %d" % current_round

func generate_pattern(round_num):
	var pattern_length = ROUND_PATTERNS[round_num - 1]
	var pattern = []
	for i in range(pattern_length):
		var icon
		while true:
			icon = randi() % 5  # Randomly pick one of the 5 icons
			if i < MAX_ICON_REPEAT or icon != pattern[i - 1] or icon != pattern[i - 2]:
				break
		pattern.append(icon)
	return pattern

func show_pattern(pattern):
	var delay = 1.0  # Delay between flashing icons
	for i in range(pattern.size()):
		timer.start(delay * i)
		timer.connect("timeout", Callable(self, "_flash_icon").bind([pattern[i]]))

func _flash_icon(icon_index):
	# Code to visually flash the icon (highlight, animate, etc.)
	var icon_node = pattern_display.get_child(icon_index)
	icon_node.modulate = Color(1, 1, 1, 1)  # Example highlight effect
	await get_tree().create_timer(0.5).timeout  # Flash duration
	icon_node.modulate = Color(1, 1, 1, 0.5)  # Back to normal
	if icon_index == current_pattern.size() - 1:
		start_player_turn()

func start_player_turn():
	is_player_turn = true
	# Allow player input here, possibly set a timer for time limit

func _on_texture_button_pressed(button_index):
	if is_player_turn:
		player_sequence.append(button_index)
		# Add feedback here (highlight, sound, etc.)
		if player_sequence.size() == current_pattern.size():
			submit_button.disabled = false

func _on_submit_pressed():
	if player_sequence == current_pattern:
		current_round += 1
		if current_round <= ROUND_PATTERNS.size():
			start_round(current_round)
		else:
			# Player has completed all rounds, handle victory
			pass
	else:
		# Player failed, handle retry or game over
		if current_round == 4:
			start_round(4)
		else:
			start_round(1)
