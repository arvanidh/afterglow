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
	var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
	if target == null:
		return
	_cd = float(_stats()["interval"])
	var origin := global_position + (_dir_to(target) * PlayerSpark.RADIUS)
	var dir := _dir_to(target)
	var bolt: PulseBolt = arena.acquire_bolt()
	bolt.launch(origin, dir, int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0)))))
	Audio.play("shoot", -8.0)
	# Twin Filament fork
	if randf() < float(mods.get("fork_chance", 0.0)):
		var fork: PulseBolt = arena.acquire_bolt()
		fork.launch(origin, dir.rotated(0.22), int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0)))))


func _dir_to(target: Node2D) -> Vector2:
	return (target.global_position - global_position).normalized()
