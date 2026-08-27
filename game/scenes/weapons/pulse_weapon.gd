class_name PulseWeapon
extends Node2D
## PULSE BOLT — auto-fires at the nearest shadow (§5.4 weapon #1).
## Levels tighten interval, raise damage; Twin Filament passive may fork bolts.

const RANGE := 460.0
const DISPLAY_NAME := "Pulse Bolt"
const ID := "pulse"

const LEVELS := [
	{"interval": 0.45, "damage": 1},
	{"interval": 0.40, "damage": 1},
	{"interval": 0.34, "damage": 2},
	{"interval": 0.28, "damage": 2},
	{"interval": 0.22, "damage": 3},
]

var level := 1
var _cd := 0.4
var arena: Node = null
var rate_scale := 1.0   # Overdrive powerup pushes this up


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, CardDb.WEAPON_MAX_LV)


func upgrade_note() -> String:
	return "Lv%d → %d dmg · %.2fs" % [level, _stats()["damage"], _stats()["interval"]]


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
	# Target boss first, then nearest regular enemy
	var target_pos: Vector2 = Vector2.ZERO
	var has_target := false
	if arena._boss != null and arena._boss.active:
		var boss_dist := global_position.distance_to(arena._boss.global_position)
		if boss_dist < RANGE:
			target_pos = arena._boss.global_position
			has_target = true
	if not has_target:
		var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
		if target != null:
			target_pos = target.global_position
			has_target = true
	if not has_target:
		return
	_cd = float(_stats()["interval"])
	var origin := global_position + (global_position.direction_to(target_pos) * PlayerSpark.RADIUS)
	var dir := global_position.direction_to(target_pos)
	var bolt: PulseBolt = arena.acquire_bolt()
	bolt.launch(origin, dir, int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0)))))
	Audio.play("shoot", -8.0)
	# Twin Filament fork
	if randf() < float(mods.get("fork_chance", 0.0)):
		var fork: PulseBolt = arena.acquire_bolt()
		fork.launch(origin, dir.rotated(0.22), int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0)))))


func _dir_to(target: Node2D) -> Vector2:
	return (target.global_position - global_position).normalized()
