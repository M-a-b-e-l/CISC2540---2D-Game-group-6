extends Node2D

var autoloader_music
var endingmusic

# This variable will be set to true when the Cipher minigame is beaten
var is_cipher_beaten = false  # You can set this variable based on your minigame logic

func _ready() -> void:
	print("Congratulations!")

	# Stop autoloader music immediately
	autoloader_music = get_node("/root/BgMusic")
	if autoloader_music:
		autoloader_music.stop()
		print("Stopped autoloader music")

	# Start background music
	endingmusic = $WinningMusic
	if endingmusic:
		endingmusic.play()
		print("Started ending music")
