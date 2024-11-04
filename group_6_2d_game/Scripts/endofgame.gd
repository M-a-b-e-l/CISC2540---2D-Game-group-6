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

	# Connect the Quit button signal
	var quit_button = $Quit
	if quit_button:
		# Create an empty StyleBox for the normal state to remove background
		var empty_style = StyleBoxEmpty.new()
		quit_button.add_theme_stylebox_override("normal", empty_style)

		# Create a StyleBoxFlat for the hover state to add highlight color
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(1, 0, 0, 0.5)  # Change this to your desired highlight color
		quit_button.add_theme_stylebox_override("hover", hover_style)

		# Optionally adjust the text color during hover
		quit_button.add_theme_color_override("font_color_hover", Color(1, 1, 0))  # Example color for text on hover

		# Connect the Quit button signal to handle quitting
		quit_button.connect("pressed", Callable(self, "_on_quit_button_pressed"))

# Function to handle Quit button press
func _on_quit_button_pressed() -> void:
	print("Quit button pressed, exiting game.")
	get_tree().quit()
