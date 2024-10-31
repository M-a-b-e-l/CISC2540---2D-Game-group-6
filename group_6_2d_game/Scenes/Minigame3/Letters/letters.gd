extends Area2D

var selected = false
var rest_point
var rest_nodes = []

func _ready():
	rest_nodes = get_tree().get_nodes_in_group("droppable")
	rest_point = rest_nodes[0].global_position
	rest_nodes[0].select()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if Input.is_action_just_pressed("click"):
		selected = true
		
func _physics_process(delta: float):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	else:
		global_position = lerp(global_position, rest_point, 10 * delta)

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
