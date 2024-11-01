extends Node2D

@export var gridBorder = 60

var gridRect = Rect2(Vector2(gridBorder, gridBorder), Vector2(gridBorder, gridBorder))

func _draw():
	draw_rect(gridRect, Color.WHITE, false, 5, true)
