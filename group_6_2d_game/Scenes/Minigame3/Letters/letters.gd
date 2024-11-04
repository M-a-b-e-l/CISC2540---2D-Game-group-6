extends Area2D

var selected = false
var rest_point
var rest_nodes = []
@export var letter = "A"

func _ready():
	add_to_group("letters")  # Add this line
	rest_nodes = get_tree().get_nodes_in_group("droppable")
	if rest_nodes.size() > 0:
		rest_point = rest_nodes[0].global_position
		rest_nodes[0].select()

func _on_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int):
	if Input.is_action_just_pressed("click"):
		selected = true  # Set selected to true when clicked

func _physics_process(delta: float):
	if selected:
		# Move the letter toward the mouse position
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			var shortest_dist = 20
			for child in rest_nodes:
				var distance = global_position.distance_to(child.global_position)
				if distance < shortest_dist:
					child.select()
					rest_point = child.global_position
					shortest_dist = distance
					print("Letter ", letter, " placed near position: ", child.global_position)  # Debug print
