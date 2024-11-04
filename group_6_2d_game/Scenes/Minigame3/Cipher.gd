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
		
	# Get all drop zones in order (make sure they're named or positioned in left-to-right order)
	drop_zones = get_tree().get_nodes_in_group("droppable")
	# Sort drop zones by x position to ensure left-to-right order
	drop_zones.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
	
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
	print("Checking solution...") # Debug print
	
	# Go through each drop zone
	for zone in drop_zones:
		var closest_letter = null
		var shortest_dist = 20
		
		# Check all letter nodes
		var letters = get_tree().get_nodes_in_group("letters")
		print("Found ", letters.size(), " letters") # Debug print
		
		for letter in letters:
			var distance = letter.global_position.distance_to(zone.global_position)
			if distance < shortest_dist:
				closest_letter = letter
				shortest_dist = distance
		
		# Add the letter to our current word if one is close enough
		if closest_letter:
			current_word += closest_letter.letter
			print("Added letter: ", closest_letter.letter) # Debug print
	
	print("Current word: ", current_word) # Debug print
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
		GlobalState.player_position = Vector2(937, 106)
		GlobalState.daBool3 = true
	else:
		print("Cipher minigame not beaten yet.")

# Call this function when the Cipher minigame is completed
func on_cipher_beaten() -> void:
	is_cipher_beaten = true
	check_cipher_beaten()
