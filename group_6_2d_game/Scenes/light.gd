extends TextureRect

@export var player_path: NodePath
var player_node = null
var last_position: Vector2
var frames_waited = 0

func _ready():
	if player_path:
		player_node = get_node(player_path)
		if player_node:
			last_position = player_node.global_position
			print("Found player at: ", last_position)
			# Force initial material update
			_update_light_position()

func _process(_delta):
	frames_waited += 1
	if frames_waited < 2:  # Wait a couple frames for everything to initialize
		return
		
	if player_node and material:
		_update_light_position()

func _update_light_position():
	var shader_material = material as ShaderMaterial
	var rect_pos = global_position
	var rect_size = size
	var light_pos_local = (player_node.global_position - rect_pos) / rect_size
	light_pos_local = Vector2(
		clamp(light_pos_local.x, 0.0, 1.0),
		clamp(light_pos_local.y, 0.0, 1.0)
	)
	shader_material.set_shader_parameter("light_position", light_pos_local)
