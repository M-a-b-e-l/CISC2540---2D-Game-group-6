extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"VBoxContainer/Play Button".grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


func _on_how_to_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/how_to_play_scene.tscn")
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()
