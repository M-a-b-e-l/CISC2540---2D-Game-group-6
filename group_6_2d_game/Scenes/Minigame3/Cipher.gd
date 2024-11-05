extends Node2D

var autoloader_music
var music
# This variable will be set to true when the Cipher minigame is beaten
var is_cipher_beaten = false
var last_debug_time = 0.0  # Add this at the top of the script with other variables

# Add this to store the correct solution
const SOLUTION = "NORTHSTAR"
var drop_zones = []  # Will store all drop zones in order

func _ready() -> void:
	print("Cipher Game 3 started")
   
	# Stop autoloader music immediately
	autoloader_music = get_node("/root/BgMusic")
	if autoloader_music:
		autoloader_music.stop()
		print("Stopped autoloader music")
   
	# Start background music
	music = $Music
	if music:
		music.play()
		print("Started background music")

	# Hide the Game3Beat label at the start
	var game3_beat_label = $Game3Beat
	if game3_beat_label:
		game3_beat_label.hide()
		print("Hid Game3Beat label")

	# Set up and start the timer label
	var timer_label = $TimerLabel  # Assuming TimerLabel is a Label node
	timer_label.text = "3:00"
	timer_label.set_position(Vector2(1050, 600))
	timer_label.show()

	# Create and start the countdown timer
	var countdown_timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.wait_time = 1.0  # Countdown every second
	countdown_timer.autostart = true
	countdown_timer.connect("timeout", Callable(self, "_on_countdown_timer_timeout"))
	countdown_timer.start()

	# Debug check for letters
	var letters = get_tree().get_nodes_in_group("letters")
	print("Found ", letters.size(), " letters in 'letters' group")
	for letter in letters:
		print("Found letter: ", letter.letter if "letter" in letter else "no letter property")

	# Debug check for drop zones
	var zones = get_tree().get_nodes_in_group("droppable")
	print("Found ", zones.size(), " drop zones")

	# Start checking for solution
	check_solution_timer()

func _on_countdown_timer_timeout() -> void:
	var timer_label = $TimerLabel  # Make sure this matches the new label node name
	var time_parts = timer_label.text.split(":")
	var minutes = int(time_parts[0])
	var seconds = int(time_parts[1])

	if seconds == 0:
		if minutes == 0:
			print("Time's up!")
			_show_game_over()
			return
		minutes -= 1
		seconds = 59
	else:
		seconds -= 1

	# Update the timer text
	timer_label.text = "%02d:%02d" % [minutes, seconds]

	# Change the color to red in the last 30 seconds
	if minutes == 0 and seconds <= 30:
		timer_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red color

func _show_game_over() -> void:
	# Show GameOverContainer and hide everything else except the background
	var game_over_container = $GameOverContainer
	if game_over_container:
		game_over_container.visible = true
		print("Showing GameOverContainer")

	# Hide all other elements except the background and GameOverContainer
	var background = $CanvasLayer/Parallax2D/TextureRect
	var all_nodes = get_children()
	for node in all_nodes:
		if node != game_over_container and node != $CanvasLayer and node is CanvasItem:
			node.visible = false

	# Make sure the background remains visible
	if background:
		background.visible = true

	# Connect the buttons to their actions
	var main_menu_button = $GameOverContainer/MainMenuButton
	var retry_button = $GameOverContainer/RetryButton

	# Use Callable for is_connected
	if main_menu_button and not main_menu_button.is_connected("pressed", Callable(self, "_on_main_menu_button_pressed")):
		main_menu_button.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))

	if retry_button and not retry_button.is_connected("pressed", Callable(self, "_on_retry_button_pressed")):
		retry_button.connect("pressed", Callable(self, "_on_retry_button_pressed"))

func _on_main_menu_button_pressed() -> void:
	print("Main menu button pressed, transitioning to main map.")
	# Stop any music and transition to main scene
	if music:
		music.stop()
	if autoloader_music:
		autoloader_music.play()

	GlobalState.daBool3 = false
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	GlobalState.player_position = Vector2(940, 100)  # New position for main menu

func _on_retry_button_pressed() -> void:
	print("Retry button pressed, reloading scene.")
	get_tree().reload_current_scene()

func check_solution_timer():
	# Create a timer to check less frequently
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5  # Check every half second
	timer.timeout.connect(check_current_solution)
	timer.start()

func check_current_solution():
	var current_word = ""
	var letters = get_tree().get_nodes_in_group("letters")
	var zones = get_tree().get_nodes_in_group("droppable")
	var used_letters = []
	
	# Only print debug messages every 4 seconds
	var current_time = Time.get_ticks_msec() / 1000.0
	var should_debug = (current_time - last_debug_time) >= 4.0
	
	if should_debug:
		last_debug_time = current_time
		print("\nChecking solution...") # Added to show when checks occur
	
	var used_zones = zones
	
	for zone in used_zones:
		var closest_letter = null
		var shortest_dist = 75.0
		
		for letter in letters:
			if letter not in used_letters:
				var distance = letter.global_position.distance_to(zone.global_position)
				if distance < shortest_dist:
					closest_letter = letter
					shortest_dist = distance
		
		if closest_letter:
			current_word += closest_letter.letter
			used_letters.append(closest_letter)
	
	# Only print word attempts during debug cycles
	if current_word != "" and should_debug:
		print("Word attempt: '", current_word, "'")
	if current_word == "NORTHSTAR":
		print("Solution found!")
		on_cipher_beaten()

func check_cipher_beaten() -> void:
	if is_cipher_beaten:
		print("Cipher minigame beaten! Transitioning to main map")
		
		# Stop minigame music and restart main music
		if music:
			music.stop()
		if autoloader_music:
			autoloader_music.play()
		
		# Change to the next scene
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
		GlobalState.player_position = Vector2(890, 106)
		GlobalState.daBool3 = true
	else:
		print("Cipher minigame not beaten yet.")

# Call this function when the Cipher minigame is completed
func on_cipher_beaten() -> void:
	is_cipher_beaten = true

	# Wait for 1-2 seconds to show the final anagram
	print("Showing final anagram for 1.0 seconds...")
	await get_tree().create_timer(1.0).timeout

	# Show the Game3Beat label
	var game3_beat_label = $Game3Beat
	if game3_beat_label:
		game3_beat_label.visible = true
		print("Showing Game3Beat label")

	# Reference the background texture
	var background = $CanvasLayer/Parallax2D/TextureRect

	# Hide all other elements except the background and Game3Beat label
	var all_nodes = get_children()
	for node in all_nodes:
		if node != game3_beat_label and node != $CanvasLayer and node is CanvasItem:
			node.visible = false

	# Make sure the background remains visible
	if background:
		background.visible = true

	# Wait for 3 seconds, then move to the next scene
	await get_tree().create_timer(3.0).timeout
	print("Transitioning to main map")

	# Stop minigame music and restart main music
	if music:
		music.stop()
	if autoloader_music:
		autoloader_music.play()

	#Change to the next scene
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	GlobalState.player_position = Vector2(890, 106)
	GlobalState.daBool3 = true
