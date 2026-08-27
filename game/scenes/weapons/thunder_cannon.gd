class_name ThunderCannon
extends Node2D
## THUNDER CANNON — evolved from Pulse + Nova.
## Massive bolts that chain to nearby enemies.

const RANGE := 520.0
const DISPLAY_NAME := "Thunder Cannon"
const ID := "thunder_cannon"
const EVOLVED := true

const LEVELS := [
	{"interval": 0.9, "damage": 8, "chain": 4, "chain_range": 180.0},
	{"interval": 0.8, "damage": 10, "chain": 5, "chain_range": 200.0},
	{"interval": 0.7, "damage": 12, "chain": 6, "chain_range": 220.0},
	{"interval": 0.6, "damage": 15, "chain": 7, "chain_range": 240.0},
	{"interval": 0.5, "damage": 18, "chain": 8, "chain_range": 260.0},
]

var level := 1
var _cd := 0.9
var arena: Node = null
var rate_scale := 1.0

func _stats() -> Dictionary: return LEVELS[mini(level - 1, LEVELS.size() - 1)]
func level_up() -> void: level = mini(level + 1, 5)
func upgrade_note() -> String: return "EVOLVED Lv%d → %d dmg · %d chains" % [level, _stats()["damage"], _stats()["chain"]]
func _player_mods() -> Dictionary: return (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}

func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena): return
	var mods := _player_mods()
	_cd -= delta * rate_scale * float(mods.get("rate_mult", 1.0))
	if _cd > 0.0: return
	_cd = float(_stats()["interval"])
	var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
	if target == null: return
	var dmg := int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0))))
	_fire_chain(target, dmg)

func _fire_chain(target: ShadowEnemy, dmg: int) -> void:
	var dir := global_position.direction_to(target.global_position)
	var origin := global_position + (dir * PlayerSpark.RADIUS)
	# Visual bolt
	var bolt := CPUParticles2D.new()
	bolt.position = target.global_position
	bolt.one_shot = true; bolt.emitting = true; bolt.amount = 16; bolt.lifetime = 0.3
	bolt.explosiveness = 1.0; bolt.spread = 180.0; bolt.gravity = Vector2.ZERO
	bolt.initial_velocity_min = 40.0; bolt.initial_velocity_max = 120.0
	bolt.color = Color(1.0, 0.84, 0.0, 0.9)
	arena.world.add_child(bolt)
	arena.get_tree().create_timer(0.5).timeout.connect(bolt.queue_free)
	# Hit primary
	Audio.play("shoot", -4.0)
	arena.hud.spawn_float(target.global_position, str(dmg), Color(1.0, 0.84, 0.0))
	if target.take_hit(dmg): arena.kill_enemy(target)
	# Chain
	var chain_count := int(_stats()["chain"])
	var chain_range: float = float(_stats()["chain_range"])
	var hit: Array[ShadowEnemy] = [target]
	var cur_pos := target.global_position
	var chain_dmg := maxi(dmg / 2, 2)
	for i in range(chain_count):
		var next: ShadowEnemy = arena.nearest_enemy_excluding(cur_pos, chain_range, hit)
		if next == null: break
		# Chain visual
		var cb := CPUParticles2D.new()
		cb.position = next.global_position
		cb.one_shot = true; cb.emitting = true; cb.amount = 8; cb.lifetime = 0.2
		cb.explosiveness = 1.0; cb.spread = 180.0; cb.gravity = Vector2.ZERO
		cb.color = Color(1.0, 0.6, 0.0, 0.8)
		arena.world.add_child(cb)
		arena.get_tree().create_timer(0.4).timeout.connect(cb.queue_free)
		arena.hud.spawn_float(next.global_position, str(chain_dmg), Color(1.0, 0.6, 0.0))
		if next.take_hit(chain_dmg): arena.kill_enemy(next)
		hit.append(next); cur_pos = next.global_position
		chain_dmg = maxi(chain_dmg - 1, 1)
