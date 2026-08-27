class_name GridLayer
extends Node2D
## Infinite neon grid floor — themed per biome (§9).

const CELL := 140.0

# Biome themes: grid_color, accent_color, bg_color
const BIOMES := {
	"promenade": {
		"grid": Color("151b33"),
		"accent": Color(0.0, 0.94, 1.0, 0.05),
		"bg": Color(0.02, 0.02, 0.04),
	},
	"sewers": {
		"grid": Color("1a2e15"),
		"accent": Color(0.3, 1.0, 0.2, 0.06),
		"bg": Color(0.01, 0.03, 0.01),
	},
	"sky": {
		"grid": Color("1b1533"),
		"accent": Color(0.8, 0.4, 1.0, 0.05),
		"bg": Color(0.02, 0.01, 0.04),
	},
}

var center := Vector2.ZERO
var half_view := Vector2(400, 700)
var biome := "promenade"


func set_biome(id: String) -> void:
	biome = id
	queue_redraw()


func track(cam_target: Vector2, view_half: Vector2) -> void:
	center = cam_target
	half_view = view_half
	queue_redraw()


func _draw() -> void:
	var theme: Dictionary = BIOMES.get(biome, BIOMES["promenade"])
	var grid_col: Color = theme["grid"]
	var accent_col: Color = theme["accent"]
	var from := Vector2(floorf((center.x - half_view.x) / CELL), floorf((center.y - half_view.y) / CELL)) * CELL
	var to := Vector2(ceilf((center.x + half_view.x) / CELL), ceilf((center.y + half_view.y) / CELL)) * CELL
	var x := from.x
	while x <= to.x + 1.0:
		draw_line(Vector2(x, from.y), Vector2(x, to.y), grid_col, 2.0)
		x += CELL
	var y := from.y
	while y <= to.y + 1.0:
		draw_line(Vector2(from.x, y), Vector2(to.x, y), grid_col, 2.0)
		y += CELL
	# Sparse accent dots at intersections
	var gx := from.x
	while gx <= to.x + 1.0:
		var gy := from.y
		while gy <= to.y + 1.0:
			if fposmod(gx / CELL + gy / CELL, 7.0) < 0.01:
				draw_circle(Vector2(gx, gy), 3.0, accent_col)
			gy += CELL
		gx += CELL
