extends Node2D

var autoloader_music
var music

# This variable will be set to true when the Cipher minigame is beaten
var is_cipher_beaten = false  # You can set this variable based on your minigame logic

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

func check_cipher_beaten() -> void:
	if is_cipher_beaten:
		print("Cipher minigame beaten! Transitioning to EndofGame scene...")
		get_tree().change_scene_to_file("res://Scenes/endofgame.tscn")
	else:
		print("Cipher minigame not beaten yet.")

# Call this function when the Cipher minigame is completed
func on_cipher_beaten() -> void:
	is_cipher_beaten = true
	check_cipher_beaten()
