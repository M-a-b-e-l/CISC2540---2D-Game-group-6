extends TextureRect

@export var player_path: NodePath
var player_node: Node2D = null
var last_position: Vector2
var frames_waited = 0
var light_radius = 0.05  # Changed to 0.05

func _ready():
	print("TextureRect _ready starting")
	print("Material exists: ", material != null)
	print("Material is ShaderMaterial: ", material is ShaderMaterial if material else "No material")
	
	# Set initial radius
	if material:
		var shader_material = material as ShaderMaterial
		shader_material.set_shader_parameter("light_radius", light_radius)
		print("Initial light radius set to: ", light_radius)
	
	if player_path:
		player_node = get_node(player_path)
		if player_node:
			last_position = player_node.global_position
			print("Found player at: ", last_position)

func _process(_delta):
	if not material:
		return
		
	if player_node and material:
		var shader_material = material as ShaderMaterial
		
		# Get viewport size and camera zoom
		var viewport_size = get_viewport_rect().size
		
		# Find camera directly as a child of player
		var zoom = 1.0
		for child in player_node.get_children():
			if child is Camera2D:
				zoom = child.zoom.x
				break
		
		var player_pos = player_node.global_position
		viewport_size *= zoom
		
		var light_pos = Vector2(
			player_pos.x / viewport_size.x,
			player_pos.y / viewport_size.y
		)
		
		shader_material.set_shader_parameter("light_position", light_pos)
		# Ensure radius stays at 0.05
		shader_material.set_shader_parameter("light_radius", 0.10)
