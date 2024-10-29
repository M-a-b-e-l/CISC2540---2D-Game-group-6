extends CharacterBody2D

@export var speed: float = 40.0
var direction: Vector2 = Vector2.ZERO

# Reference to the Player Sprite2D node and its AnimationPlayer
@onready var sprite = $CollisionShape2D/Player
@onready var animation_player = $CollisionShape2D/Player/AnimationPlayer

func _physics_process(_delta):
	# Capture input for movement
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	elif Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Normalize direction to ensure consistent movement speed
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		
		# Move the character
		velocity = direction * speed
		move_and_slide()
		# Play corresponding animation based on movement direction
		if direction.x > 0:
			animation_player.play("WalkingRight")
		elif direction.x < 0:
			animation_player.play("WalkingLeft")
		elif direction.y > 0:
			animation_player.play("WalkingDown")
		elif direction.y < 0:
			animation_player.play("WalkingUp")
	else:
		# Play the idle animation when the character is not moving
		velocity = Vector2.ZERO
		animation_player.play("Idle")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Minigame1"):
		#Use call_deferred to change scene safely
		get_tree().call_deferred("change_scene_to_file", "res://scenes/MatchingGame1.tscn")
		
	if area.is_in_group("Portal"):
		position.x = 525
		position.y = 340
		
	if area.is_in_group("Portal2"):
		position.x = 613
		position.y = 490
		
	if area.is_in_group("Portal3"):
		position.x = 967
		position.y = 106
		
	if area.is_in_group("AntiPortal1"):
		position.x = 315
		position.y = 103
		
	if area.is_in_group("AntiPortal2"):
		position.x = 525
		position.y = 380
		
	if area.is_in_group("AntiPortal3"):
		position.x = 613
		position.y = 490
