extends CharacterBody2D

@export var speed: float = 200.0
var direction: Vector2 = Vector2.ZERO

# Reference to the Player Sprite2D node and its AnimationPlayer
@onready var sprite = $Player
@onready var animation_player = $Player/AnimationPlayer

func _physics_process(_delta):
	# Capture input for movement
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1
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
