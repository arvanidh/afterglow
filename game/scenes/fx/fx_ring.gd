class_name FxRing
extends Node2D
## Expanding shockwave ring — the "graphical" in every kill (§7.3 juice list).
## Pool-managed by the arena like everything else.

var life := 0.0
var duration := 0.28
var max_radius := 46.0
var color := Color(1, 1, 1, 0.8)
var active := false


func fire(at: Vector2, p_max_radius: float, p_color: Color, p_duration := 0.28) -> void:
	global_position = at
	max_radius = p_max_radius
	color = p_color
	duration = p_duration
	life = duration
	active = true
	show()


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active:
		return
	life -= delta
	if life <= 0.0:
		release()
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var t := 1.0 - life / duration
	var r := max_radius * (0.15 + 0.85 * t)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(color.r, color.g, color.b, color.a * (1.0 - t)), 3.0 - 2.0 * t)
