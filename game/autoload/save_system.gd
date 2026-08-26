extends Node
## Local JSON saves in user:// — schema-versioned per GDD §12.3.
## Cloud sync (Play Games Saved Games) attaches behind this same interface later.

const SAVE_PATH := "user://save.json"
const SCHEMA_VERSION := 1

const DEFAULTS := {
	"schema": SCHEMA_VERSION,
	"total_shards": 0,
	"best_time": 0.0,
	"best_level": 1,
	"runs": 0,
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
		return parsed
	push_warning("SaveSystem: unreadable/newer schema — defaults returned")
	return DEFAULTS.duplicate(true)


func mark_run_finished(level_reached := 1) -> void:
	var data := load_save()
	data["runs"] = int(data.get("runs", 0)) + 1
	data["total_shards"] = int(data.get("total_shards", 0)) + RunState.shards
	data["best_time"] = maxf(float(data.get("best_time", 0.0)), RunState.time_alive)
	data["best_level"] = maxi(int(data.get("best_level", 1)), level_reached)
	save(data)
