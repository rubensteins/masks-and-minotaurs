@tool #make sure it gets run in the editor
extends Control

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color.BLACK)
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)

	draw_line(Vector2(16.0, 0.0), Vector2(24.0, 0.0), Color.WHITE, 2)
	draw_line(Vector2(-16.0, 0.0), Vector2(-24.0, 0.0), Color.WHITE, 2)
	draw_line(Vector2(0, 16.0), Vector2(0, 24.0), Color.WHITE, 2)
	draw_line(Vector2(0, -16.0), Vector2(0, -24.0), Color.WHITE, 2)
