extends Node
## Missions & Achievements — track goals and reward gems on completion.

const SAVE_PATH := "user://missions.json"

# Mission definitions
const MISSIONS := {
	"kill_100": {"title": "Shadow Slayer", "desc": "Kill 100 shadows total", "target": 100, "reward": 20},
	"kill_500": {"title": "Shadow Hunter", "desc": "Kill 500 shadows total", "target": 500, "reward": 50},
	"kill_1000": {"title": "Shadow Master", "desc": "Kill 1000 shadows total", "target": 1000, "reward": 100},
	"reach_level_10": {"title": "Promenade Pro", "desc": "Reach level 10", "target": 10, "reward": 30},
	"reach_level_20": {"title": "Sewer Explorer", "desc": "Reach level 20", "target": 20, "reward": 60},
	"reach_level_30": {"title": "Sky Dominator", "desc": "Reach level 30", "target": 30, "reward": 100},
	"beat_boss_1": {"title": "Watchman Down", "desc": "Defeat The Watcher", "target": 1, "reward": 40},
	"beat_boss_2": {"title": "Devourer Denied", "desc": "Defeat The Devourer", "target": 1, "reward": 80},
	"beat_boss_3": {"title": "Void Vanquished", "desc": "Defeat The Void", "target": 1, "reward": 150},
	"earn_100_gems": {"title": "Gem Collector", "desc": "Earn 100 gems total", "target": 100, "reward": 25},
	"earn_500_gems": {"title": "Gem Hoarder", "desc": "Earn 500 gems total", "target": 500, "reward": 75},
	"play_10_runs": {"title": "Regular", "desc": "Complete 10 runs", "target": 10, "reward": 30},
	"play_50_runs": {"title": "Dedicated", "desc": "Complete 50 runs", "target": 50, "reward": 80},
	"collect_6_weapons": {"title": "Arsenal", "desc": "Collect all 6 weapons in a single run", "target": 1, "reward": 50},
	"combo_20": {"title": "Combo King", "desc": "Reach a 20-kill combo", "target": 20, "reward": 40},
	"no_death_level_5": {"title": "Untouchable", "desc": "Reach level 5 without dying", "target": 1, "reward": 35},
}


func _ready() -> void:
	# Ensure progress file exists
	_load()


func track_kill() -> void:
	var data := _load()
	data["total_kills"] = int(data.get("total_kills", 0)) + 1
	_save(data)
	_check_all()


func track_level(level: int) -> void:
	var data := _load()
	var best := int(data.get("best_level", 0))
	if level > best:
		data["best_level"] = level
	_save(data)
	_check_all()


func track_boss(boss_name: String) -> void:
	var data := _load()
	if boss_name == "THE WATCHER":
		data["bosses_killed_watcher"] = int(data.get("bosses_killed_watcher", 0)) + 1
	elif boss_name == "THE DEVOURER":
		data["bosses_killed_devourer"] = int(data.get("bosses_killed_devourer", 0)) + 1
	elif boss_name == "THE VOID":
		data["bosses_killed_void"] = int(data.get("bosses_killed_void", 0)) + 1
	_save(data)
	_check_all()


func track_gems(amount: int) -> void:
	var data := _load()
	data["total_gems"] = int(data.get("total_gems", 0)) + amount
	_save(data)
	_check_all()


func track_run() -> void:
	var data := _load()
	data["total_runs"] = int(data.get("total_runs", 0)) + 1
	_save(data)
	_check_all()


func track_combo(combo: int) -> void:
	var data := _load()
	var best := int(data.get("best_combo", 0))
	if combo > best:
		data["best_combo"] = combo
	_save(data)
	_check_all()


func track_weapons_collected(count: int) -> void:
	var data := _load()
	if count >= 6:
		data["all_weapons_once"] = true
	_save(data)
	_check_all()


func track_no_death_level(level: int) -> void:
	var data := _load()
	if level >= 5 and int(data.get("deaths", 999)) == 0:
		data["no_death_level_5"] = true
	_save(data)
	_check_all()


func get_progress() -> Array:
	var data := _load()
	var result := []
	for id: String in MISSIONS:
		var m: Dictionary = MISSIONS[id]
		var progress := _get_progress_for(id, data)
		var completed := progress >= int(m["target"])
		var claimed := int(data.get("claimed_" + id, 0)) > 0
		result.append({
			"id": id,
			"title": m["title"],
			"desc": m["desc"],
			"progress": mini(progress, int(m["target"])),
			"target": int(m["target"]),
			"completed": completed,
			"claimed": claimed,
			"reward": int(m["reward"]),
		})
	return result


func claim_reward(id: String) -> int:
	var data := _load()
	if int(data.get("claimed_" + id, 0)) > 0:
		return 0
	var m: Dictionary = MISSIONS.get(id, {})
	if m.is_empty():
		return 0
	var progress := _get_progress_for(id, data)
	if progress < int(m["target"]):
		return 0
	data["claimed_" + id] = 1
	_save(data)
	var reward: int = int(m["reward"])
	SaveSystem.add_gems(reward)
	return reward


func _get_progress_for(id: String, data: Dictionary) -> int:
	match id:
		"kill_100", "kill_500", "kill_1000":
			return int(data.get("total_kills", 0))
		"reach_level_10", "reach_level_20", "reach_level_30":
			return int(data.get("best_level", 0))
		"beat_boss_1":
			return int(data.get("bosses_killed_watcher", 0))
		"beat_boss_2":
			return int(data.get("bosses_killed_devourer", 0))
		"beat_boss_3":
			return int(data.get("bosses_killed_void", 0))
		"earn_100_gems", "earn_500_gems":
			return int(data.get("total_gems", 0))
		"play_10_runs", "play_50_runs":
			return int(data.get("total_runs", 0))
		"collect_6_weapons":
			return 1 if data.get("all_weapons_once", false) else 0
		"combo_20":
			return int(data.get("best_combo", 0))
		"no_death_level_5":
			return 1 if data.get("no_death_level_5", false) else 0
	return 0


func _check_all() -> void:
	# Could emit signals for UI updates
	pass


func _load() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		return parsed
	return {}


func _save(data: Dictionary) -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
