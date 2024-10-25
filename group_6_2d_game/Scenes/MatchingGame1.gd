extends Node2D  # MatchingGame1 is a Node2D, so we extend Node2D

var correct_pattern = []  # Stores the correct pattern of icons
var player_input = []     # Stores the player's input
var current_round = 1     # Track which round the player is on

@onready var icon_nodes = [
	$PatternDisplay/Icon1,
	$PatternDisplay/Icon2,
	$PatternDisplay/Icon3,
	$PatternDisplay/Icon4,
	$PatternDisplay/Icon5
]

@onready var buttons = [
	$PlayerInput/TextureButton,
	$PlayerInput/TextureButton2,
	$PlayerInput/TextureButton3,
	$PlayerInput/TextureButton4,
	$PlayerInput/TextureButton5
]

@onready var submit_button = $PlayerInput/SubmitButton  # If you have a Submit button

func _ready():
	# Start the first round
	_start_round(current_round)

func _start_round(round):
	player_input.clear()  # Reset player input for the new round
	
	# Set pattern length based on the round (e.g., 3 icons in round 1, increasing each round)
	var pattern_length = 2 + round  # For round 1, the pattern length will be 3, increasing by 1 each round

	# Generate a random pattern based on the available icons
	correct_pattern = []
	for i in range(pattern_length):
		var random_index = randi() % icon_nodes.size()
		correct_pattern.append(random_index)

	# Show the pattern to the player
	await _show_pattern(correct_pattern)

func _show_pattern(pattern) -> void:
	# Display the pattern to the player (e.g., flash icons)
	for i in range(pattern.size()):
		await get_tree().create_timer(0.5).timeout  # Wait half a second between each icon flash
		icon_nodes[pattern[i]].modulate = Color(1, 1, 1)  # Flash icon by setting its color
		await get_tree().create_timer(0.5).timeout
		icon_nodes[pattern[i]].modulate = Color(0.5, 0.5, 0.5)  # Return to normal after the flash

func _on_button_pressed(index):
	# This is called when a TextureButton is clicked
	print("Button ", index, " pressed!")
	player_input.append(index)  # Store the player's input

	# Add visual feedback on the button, e.g., change color
	buttons[index].modulate = Color(0.5, 1, 0.5)  # Greenish tint when clicked

	# Check if the player's input matches the correct pattern length
	if player_input.size() == correct_pattern.size():
		_on_submit_pressed()

func _on_submit_pressed():
	# Compare player_input with correct_pattern
	if player_input == correct_pattern:
		_on_success()
	else:
		_on_failure()

func _on_success():
	print("Correct Pattern!")
	current_round += 1  # Move to the next round
	
	if current_round <= 5:
		_start_round(current_round)  # Start the next round
	else:
		print("You completed all rounds! Well done!")
		# You can end the game here, show a success screen, etc.

func _on_failure():
	print("Wrong Pattern! Try Again.")
	player_input.clear()
	# Restart the same round if failed
	_start_round(current_round)
