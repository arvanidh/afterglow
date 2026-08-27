extends Node
## Local JSON saves in user:// — schema-versioned per GDD §12.3.
## v2: gems, permanent upgrades, level star-ratings, weapon unlocks.

const SAVE_PATH := "user://save.json"
const SCHEMA_VERSION := 2

const DEFAULTS := {
	"schema": SCHEMA_VERSION,
	"total_shards": 0,
	"gems": 0,
	"best_time": 0.0,
	"best_level": 1,
	"highest_unlocked": 1,
	"runs": 0,
	"selected_character": "spark",
	"upgrades": {},
	"unlocked_weapons": ["pulse"],
	"level_stars": {},
}

const UPGRADES := {
	"max_hp": {"title": "Extra Heart", "desc": "+1 max HP", "costs": [15, 40, 80, 150, 250], "max": 5, "category": "vitality"},
	"start_weapon": {"title": "Armed Start", "desc": "Start with Orbit Blades", "costs": [50], "max": 1, "category": "offense"},
	"start_weapon_nova": {"title": "Nova Start", "desc": "Start with Nova Burst", "costs": [80], "max": 1, "category": "offense"},
	"magnet_range": {"title": "Magnet Core", "desc": "+30% pickup reach", "costs": [20, 50], "max": 2, "category": "utility"},
	"xp_boost": {"title": "Quick Study", "desc": "+25% XP gain", "costs": [30, 70], "max": 2, "category": "utility"},
	"crit_chance": {"title": "Lucky Strike", "desc": "+8% crit chance", "costs": [40, 90, 160], "max": 3, "category": "offense"},
	# Meta progression — deeper upgrade tree
	"gem_magnet": {"title": "Gem Magnet", "desc": "Enemies drop 1 extra gem every 5 kills", "costs": [60, 120], "max": 2, "category": "economy"},
	"revive": {"title": "Second Wind", "desc": "Revive once per run with 1 HP", "costs": [200], "max": 1, "category": "vitality"},
	"start_shield": {"title": "Shield Start", "desc": "Start each run with +1 HP", "costs": [100], "max": 1, "category": "vitality"},
	"combo_master": {"title": "Combo Master", "desc": "+20% combo fire rate bonus", "costs": [80, 160], "max": 2, "category": "offense"},
	"treasure_hunter": {"title": "Treasure Hunter", "desc": "+50% gem drops from bosses", "costs": [150], "max": 1, "category": "economy"},
	"glass_cannon": {"title": "Glass Cannon", "desc": "+40% damage, -1 max HP", "costs": [120], "max": 1, "category": "offense"},
}


func save(data: Dictionary) -> bool:
	data["schema"] = SCHEMA_VERSION
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveSystem: cannot write %s" % SAVE_PATH)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true


func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return DEFAULTS.duplicate(true)
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return DEFAULTS.duplicate(true)
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary and int(parsed.get("schema", 0)) <= SCHEMA_VERSION:
		# Migration: ensure all keys exist
		for key: String in DEFAULTS:
			if not parsed.has(key):
				parsed[key] = DEFAULTS[key]
		return parsed
	push_warning("SaveSystem: unreadable/newer schema — defaults returned")
	return DEFAULTS.duplicate(true)


func mark_run_finished(level_reached := 1, gems_earned := 0, time_alive := 0.0) -> void:
	var data := load_save()
	data["runs"] = int(data.get("runs", 0)) + 1
	data["total_shards"] = int(data.get("total_shards", 0)) + RunState.shards
	data["best_time"] = maxf(float(data.get("best_time", 0.0)), time_alive)
	data["best_level"] = maxi(int(data.get("best_level", 1)), level_reached)
	data["gems"] = int(data.get("gems", 0)) + gems_earned
	# Star rating for the level reached (3 = no deaths, 2 = 1 death, 1 = survived)
	var star := 1
	if RunState.deaths == 0:
		star = 3
	elif RunState.deaths == 1:
		star = 2
	var key := str(level_reached)
	var prev := int(data.get("level_stars", {}).get(key, 0))
	if star > prev:
		if not data["level_stars"] is Dictionary:
			data["level_stars"] = {}
		data["level_stars"][key] = star
	save(data)


func get_gems() -> int:
	return int(load_save().get("gems", 0))


func spend_gems(amount: int) -> bool:
	var data := load_save()
	var cur: int = int(data.get("gems", 0))
	if cur < amount:
		return false
	data["gems"] = cur - amount
	save(data)
	return true


func add_gems(amount: int) -> void:
	var data := load_save()
	data["gems"] = int(data.get("gems", 0)) + amount
	save(data)


func get_upgrade_level(id: String) -> int:
	var data := load_save()
	return int(data.get("upgrades", {}).get(id, 0))


func buy_upgrade(id: String) -> bool:
	var def: Dictionary = UPGRADES.get(id, {})
	if def.is_empty():
		return false
	var data := load_save()
	var ups: Dictionary = data.get("upgrades", {})
	var cur_lv: int = int(ups.get(id, 0))
	if cur_lv >= int(def["max"]):
		return false
	var costs: Array = def["costs"]
	if cur_lv >= costs.size():
		return false
	var cost: int = int(costs[cur_lv])
	var gems: int = int(data.get("gems", 0))
	if gems < cost:
		return false
	data["gems"] = gems - cost
	ups[id] = cur_lv + 1
	data["upgrades"] = ups
	save(data)
	return true


func set_selected_character(id: String) -> void:
	var data := load_save()
	data["selected_character"] = id
	save(data)


func get_selected_character() -> String:
	return load_save().get("selected_character", "spark")


func unlock_next_level(reached: int) -> void:
	var data := load_save()
	var cur: int = int(data.get("highest_unlocked", 1))
	if reached >= cur:
		data["highest_unlocked"] = reached + 1
		save(data)


func get_highest_unlocked() -> int:
	return int(load_save().get("highest_unlocked", 1))


func has_weapon(id: String) -> bool:
	var data := load_save()
	var weapons: Array = data.get("unlocked_weapons", ["pulse"])
	return weapons.has(id)


func unlock_weapon(id: String) -> void:
	var data := load_save()
	var weapons: Array = data.get("unlocked_weapons", ["pulse"])
	if not weapons.has(id):
		weapons.append(id)
		data["unlocked_weapons"] = weapons
		save(data)


func get_level_stars() -> Dictionary:
	var data := load_save()
	var raw = data.get("level_stars", {})
	if raw is Dictionary:
		return raw
	return {}
