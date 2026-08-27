class_name MiniBoss
extends Node2D
## Mini-boss: smaller than a regular boss but tougher than elites.
## Spawns at levels 5, 15, 25 between regular boss fights.

signal died(mini_boss: MiniBoss)

enum Kind { SENTINEL, CRAWLER, ORACLE }

const STATS := {
	Kind.SENTINEL: {
		"name": "SENTINEL", "hp": 25, "speed": 80.0, "radius": 22.0,
		"damage": 1, "gems": 5, "color": Color(1.0, 0.4, 0.1),
	},
	Kind.CRAWLER: {
		"name": "CRAWLER", "hp": 35, "speed": 60.0, "radius": 26.0,
		"damage": 1, "gems": 8, "color": Color(0.1, 0.8, 0.3),
	},
	Kind.ORACLE: {
		"name": "ORACLE", "hp": 45, "speed": 50.0, "radius": 30.0,
		"damage": 2, "gems": 10, "color": Color(0.6, 0.2, 1.0),
	},
}

var kind := Kind.SENTINEL
var hp := 25
var max_hp := 25
var active := false
var _player: Node = null
var _angle := 0.0
var _attack_cd := 0.0


func setup(p_kind: Kind, player: Node) -> void:
	kind = p_kind
	_player = player
	var s: Dictionary = STATS[kind]
	hp = s["hp"]
	max_hp = s["hp"]
	_angle = 0.0
	_attack_cd = 1.0
	active = true
	show()
	queue_redraw()


func release() -> void:
	active = false
	hide()


func take_hit(dmg: int) -> bool:
	hp -= dmg
	queue_redraw()
	if hp <= 0:
		active = false
		died.emit(self)
		return true
	return false


func _process(delta: float) -> void:
	if not active or _player == null:
		return
	var s: Dictionary = STATS[kind]
	# Orbit around the player
	_angle += delta * 2.5
	var orbit_r := 160.0
	var target_pos: Vector2 = _player.global_position + Vector2.from_angle(_angle) * orbit_r
	global_position = global_position.lerp(target_pos, 3.0 * delta)
	# Attack periodically: charge toward player
	_attack_cd -= delta
	if _attack_cd <= 0.0:
		_attack_cd = 2.5
		# Brief speed burst
		var dir: Vector2 = global_position.direction_to(_player.global_position)
		global_position += dir * 80.0
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var s: Dictionary = STATS[kind]
	var col: Color = s["color"]
	var r: float = s["radius"]
	# Shadow body
	draw_circle(Vector2.ZERO, r, Color(0.05, 0.05, 0.1, 0.9))
	# Colored rim
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, col, 3.0)
	# Inner glow
	draw_circle(Vector2.ZERO, r * 0.4, Color(col.r, col.g, col.b, 0.5))
	# Eyes
	for i in range(-1, 2, 2):
		var eye_pos := Vector2(float(i) * r * 0.3, -r * 0.15)
		draw_circle(eye_pos, 3.0, Color(col.r, col.g, col.b, 0.9))
	# HP bar background
	var bar_w := r * 2.0
	var bar_h := 4.0
	draw_rect(Rect2(-bar_w * 0.5, -r - 10, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
	# HP bar fill
	var frac := float(hp) / float(max_hp)
	draw_rect(Rect2(-bar_w * 0.5, -r - 10, bar_w * frac, bar_h), col)
