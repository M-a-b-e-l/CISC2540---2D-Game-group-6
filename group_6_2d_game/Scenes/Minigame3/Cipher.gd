extends Node2D
var autoloader_music
var music
# This variable will be set to true when the Cipher minigame is beaten
var is_cipher_beaten = false

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

func check_solution_timer():
	# Create a timer to periodically check the solution
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5  # Check every half second
	timer.timeout.connect(check_current_solution)
	timer.start()

func check_current_solution():
	var current_word = ""
	var letters = get_tree().get_nodes_in_group("letters")
	var zones = get_tree().get_nodes_in_group("droppable")
	var used_letters = []  # Track which letters have been used
	
	print("\n--- Checking Solution ---")
	var used_zones = zones  # Only use first 9 zones for NORTH STAR
	
	for zone in used_zones:
		print("\nChecking zone at: ", zone.global_position)
		var closest_letter = null
		var shortest_dist = 75.0  # Keep the more lenient distance
		
		# Find closest unused letter for this zone
		for letter in letters:
			if letter not in used_letters:  # Only consider unused letters
				var distance = letter.global_position.distance_to(zone.global_position)
				print("Letter '", letter.letter, "' distance: ", distance)
				if distance < shortest_dist:
					closest_letter = letter
					shortest_dist = distance
					print("New closest letter: '", letter.letter, "' at distance: ", distance)
		
		if closest_letter:
			current_word += closest_letter.letter
			used_letters.append(closest_letter)  # Mark this letter as used
			print("Added '", closest_letter.letter, "' to word")
	
	print("\nFinal word attempt: '", current_word, "'")
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
			
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
		GlobalState.player_position = Vector2(890, 106)
		GlobalState.daBool3 = true
	else:
		print("Cipher minigame not beaten yet.")

# Call this function when the Cipher minigame is completed
func on_cipher_beaten() -> void:
	is_cipher_beaten = true
	check_cipher_beaten()
