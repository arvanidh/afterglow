class_name GridLayer
extends Node2D
## The Promenade floor — infinite neon grid (§9 biome 1). Drawn in world space
## around the camera target every frame; only visible lines are emitted.

const CELL := 140.0
const GRID_COLOR := Color("151b33")
const ACCENT_COLOR := Color(0.0, 0.94, 1.0, 0.05)

var center := Vector2.ZERO
var half_view := Vector2(400, 700)


func track(cam_target: Vector2, view_half: Vector2) -> void:
	center = cam_target
	half_view = view_half
	queue_redraw()


func _draw() -> void:
	var from := Vector2(floorf((center.x - half_view.x) / CELL), floorf((center.y - half_view.y) / CELL)) * CELL
	var to := Vector2(ceilf((center.x + half_view.x) / CELL), ceilf((center.y + half_view.y) / CELL)) * CELL
	var x := from.x
	while x <= to.x + 1.0:
		draw_line(Vector2(x, from.y), Vector2(x, to.y), GRID_COLOR, 2.0)
		x += CELL
	var y := from.y
	while y <= to.y + 1.0:
		draw_line(Vector2(from.x, y), Vector2(to.x, y), GRID_COLOR, 2.0)
		y += CELL
	# Sparse accent dots at intersections — depth without cost.
	var gx := from.x
	while gx <= to.x + 1.0:
		var gy := from.y
		while gy <= to.y + 1.0:
			if fposmod(gx / CELL + gy / CELL, 7.0) < 0.01:
				draw_circle(Vector2(gx, gy), 3.0, ACCENT_COLOR)
			gy += CELL
		gx += CELL
