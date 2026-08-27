class_name FlameTrail
extends Node2D
## FLAME TRAIL — leaves fire patches on the ground that damage enemies.
## Unique mechanic: while moving, you leave a trail of fire that burns
## enemies who walk over it. Standing still = no fire.

const RANGE := 180.0
const DISPLAY_NAME := "Flame Trail"
const ID := "flame"

const LEVELS := [
	{"interval": 0.25, "damage": 1, "lifetime": 2.0, "patch_size": 20.0},
	{"interval": 0.22, "damage": 2, "lifetime": 2.5, "patch_size": 24.0},
	{"interval": 0.20, "damage": 2, "lifetime": 3.0, "patch_size": 28.0},
	{"interval": 0.18, "damage": 3, "lifetime": 3.5, "patch_size": 32.0},
	{"interval": 0.15, "damage": 4, "lifetime": 4.0, "patch_size": 36.0},
]

var level := 1
var _cd := 0.25
var arena: Node = null
var rate_scale := 1.0
var _patches: Array[FirePatch] = []


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "Lv%d → %d dmg · %.1fs burn" % [level, _stats()["damage"], _stats()["lifetime"]]


func _player_mods() -> Dictionary:
	return (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}


func _process(delta: float) -> void:
	if arena == null:
		return
	# Only leave trail when moving
	var player: PlayerSpark = arena.player
	if player.move_dir.length_squared() < 0.01:
		return
	# Cooldown
	var mods := _player_mods()
	var rate_total: float = rate_scale * float(mods.get("rate_mult", 1.0))
	_cd -= delta * rate_total
	if _cd > 0.0:
		return
	_cd = float(_stats()["interval"])
	# Spawn fire patch
	var stats := _stats()
	var dmg := int(ceilf(float(stats["damage"]) * float(mods.get("dmg_mult", 1.0))))
	var patch := FirePatch.new()
	patch.setup(global_position, dmg, float(stats["lifetime"]), float(stats["patch_size"]))
	arena.world.add_child(patch)
	_patches.append(patch)
	# Tick damage to nearby enemies
	_tick_damage(patch)


func _tick_damage(patch: FirePatch) -> void:
	if arena == null:
		return
	for e in arena.enemies:
		if not e.active:
			continue
		var dist := patch.global_position.distance_to(e.global_position)
		if dist < patch.size + e.radius:
			hud_spawn_float(e.global_position, str(patch.damage), Color(1.0, 0.5, 0.0))
			if e.take_hit(patch.damage):
				arena.kill_enemy(e)
	# Boss too
	if arena._boss != null and arena._boss.active:
		var dist := patch.global_position.distance_to(arena._boss.global_position)
		if dist < patch.size + arena._boss.radius:
			hud_spawn_float(arena._boss.global_position, str(patch.damage), Color(1.0, 0.5, 0.0))
			if arena._boss.take_hit(patch.damage):
				arena._on_boss_died(arena._boss)


func hud_spawn_float(at: Vector2, text: String, col: Color) -> void:
	if arena and arena.hud:
		arena.hud.spawn_float(at, text, col)


## FirePatch — a single fire patch on the ground
class FirePatch extends Node2D:
	var damage := 1
	var life := 2.0
	var size := 20.0
	var _age := 0.0

	func setup(at: Vector2, dmg: int, dur: float, sz: float) -> void:
		global_position = at
		damage = dmg
		life = dur
		size = sz
		z_index = -1

	func _process(delta: float) -> void:
		_age += delta
		if _age > life:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var alpha := 1.0 - (_age / life)
		# Flickering fire
		var flicker := 0.8 + 0.2 * sin(_age * 15.0)
		draw_circle(Vector2.ZERO, size, Color(1.0, 0.4, 0.0, 0.15 * alpha * flicker))
		draw_circle(Vector2.ZERO, size * 0.6, Color(1.0, 0.6, 0.1, 0.25 * alpha * flicker))
		draw_circle(Vector2.ZERO, size * 0.3, Color(1.0, 0.8, 0.2, 0.35 * alpha * flicker))
