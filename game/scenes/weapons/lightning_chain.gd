class_name LightningChain
extends Node2D
## LIGHTNING CHAIN — fires a bolt that chains to nearby enemies.
## Unique mechanic: each kill with this weapon has a chance to chain
## to the nearest enemy within range, dealing reduced damage per chain.

const RANGE := 420.0
const DISPLAY_NAME := "Lightning Chain"
const ID := "lightning"

const LEVELS := [
	{"interval": 0.60, "damage": 2, "chain": 1, "chain_range": 120.0},
	{"interval": 0.55, "damage": 2, "chain": 2, "chain_range": 140.0},
	{"interval": 0.50, "damage": 3, "chain": 2, "chain_range": 160.0},
	{"interval": 0.45, "damage": 3, "chain": 3, "chain_range": 180.0},
	{"interval": 0.40, "damage": 4, "chain": 4, "chain_range": 200.0},
]

var level := 1
var _cd := 0.6
var arena: Node = null
var rate_scale := 1.0


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "Lv%d → %d dmg · %d chains" % [level, _stats()["damage"], _stats()["chain"]]


func _player_mods() -> Dictionary:
	return (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}


func _process(delta: float) -> void:
	if arena == null:
		return
	var mods := _player_mods()
	var rate_total: float = rate_scale * float(mods.get("rate_mult", 1.0))
	_cd -= delta * rate_total
	if _cd > 0.0:
		return
	var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
	if target == null:
		return
	_cd = float(_stats()["interval"])
	var dmg := int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0))))
	_fire_chain(target, dmg)


func _fire_chain(target: ShadowEnemy, dmg: int) -> void:
	# Fire visual
	var dir := global_position.direction_to(target.global_position)
	var origin := global_position + (dir * PlayerSpark.RADIUS)
	_draw_lightning(origin, target.global_position)
	# Hit the primary target
	Audio.play("shoot", -6.0)
	hud_spawn_float(target.global_position, str(dmg), Color(0.4, 0.9, 1.0))
	if target.take_hit(dmg):
		arena.kill_enemy(target)
	# Chain to nearby enemies
	var chain_count := int(_stats()["chain"])
	var chain_range := float(_stats()["chain_range"])
	var hit_enemies: Array[ShadowEnemy] = [target]
	var current_pos := target.global_position
	var chain_dmg := maxi(dmg - 1, 1)  # Reduced damage per chain
	for i in range(chain_count):
		var next: ShadowEnemy = arena.nearest_enemy_excluding(current_pos, chain_range, hit_enemies)
		if next == null:
			break
		_draw_lightning(current_pos, next.global_position)
		Audio.play("hit", -7.0)
		hud_spawn_float(next.global_position, str(chain_dmg), Color(0.3, 0.7, 1.0))
		if next.take_hit(chain_dmg):
			arena.kill_enemy(next)
		hit_enemies.append(next)
		current_pos = next.global_position
		chain_dmg = maxi(chain_dmg - 1, 1)


func _draw_lightning(from: Vector2, to: Vector2) -> void:
	# Draw a jagged lightning bolt
	var segments := 6
	var dir := from.direction_to(to)
	var dist := from.distance_to(to)
	var perp := Vector2(-dir.y, dir.x)
	var points := PackedVector2Array([from])
	for i in range(1, segments):
		var t := float(i) / float(segments)
		var pos := from.lerp(to, t)
		var offset := perp * randf_range(-20.0, 20.0) * (1.0 - absf(t - 0.5) * 2.0)
		points.append(pos + offset)
	points.append(to)
	# Draw glow
	var glow_col := Color(0.4, 0.9, 1.0, 0.3)
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], glow_col, 6.0)
	# Draw core
	var core_col := Color(0.75, 1.0, 1.0, 0.9)
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], core_col, 2.0)
	# Auto-fade the visual
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)


func hud_spawn_float(at: Vector2, text: String, col: Color) -> void:
	if arena and arena.hud:
		arena.hud.spawn_float(at, text, col)
