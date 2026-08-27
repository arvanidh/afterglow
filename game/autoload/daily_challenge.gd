extends Node
## Daily Challenge — seeded run based on today's date.
## Everyone gets the same enemies/levels. Best score saved locally.

const SAVE_PATH := "user://daily.json"


func get_today_seed() -> int:
	# Seed based on year/month/day — same for everyone on the same day
	var today := Time.get_datetime_dict_from_system()
	var hash_val: int = int(today["year"]) * 10000 + int(today["month"]) * 100 + int(today["day"])
	return hash_val


func get_today_string() -> String:
	var today := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [today["year"], today["month"], today["day"]]


func is_daily_completed() -> bool:
	var data := _load()
	var date_str := get_today_string()
	return data.has(date_str)


func get_daily_best() -> Dictionary:
	var data := _load()
	var date_str := get_today_string()
	if data.has(date_str):
		return data[date_str]
	return {}


func save_daily_result(level: int, kills: int, gems: int, time: float) -> void:
	var data := _load()
	var date_str := get_today_string()
	var prev: Dictionary = data.get(date_str, {}) as Dictionary
	# Only save if better than previous
	if level > int(prev.get("level", 0)):
		data[date_str] = {
			"level": level,
			"kills": kills,
			"gems": gems,
			"time": snappedf(time, 0.1),
		}
		_save(data)


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
