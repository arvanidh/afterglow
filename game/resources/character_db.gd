class_name CharacterDb
extends RefCounted
## Character definitions — Spark, Ember, Volt. Each has unique stats and starting weapon.

enum Id { SPARK, EMBER, VOLT }

const CHARACTERS := {
	Id.SPARK: {
		"id": "spark",
		"name": "SPARK",
		"desc": "Balanced all-rounder. The original light.",
		"color": Color(0.0, 0.94, 1.0),
		"hp": 3,
		"speed_mult": 1.0,
		"damage_mult": 1.0,
		"rate_mult": 1.0,
		"start_weapon": "pulse",
	},
	Id.EMBER: {
		"id": "ember",
		"name": "EMBER",
		"desc": "Aggressive firestarter. Faster attacks, less HP.",
		"color": Color(1.0, 0.45, 0.1),
		"hp": 2,
		"speed_mult": 1.1,
		"damage_mult": 1.2,
		"rate_mult": 1.3,
		"start_weapon": "flame",
	},
	Id.VOLT: {
		"id": "volt",
		"name": "VOLT",
		"desc": "Defensive powerhouse. More HP, chain attacks.",
		"color": Color(0.5, 0.3, 1.0),
		"hp": 5,
		"speed_mult": 0.9,
		"damage_mult": 1.0,
		"rate_mult": 0.85,
		"start_weapon": "lightning",
	},
}


static func get_all() -> Array:
	return [CHARACTERS[Id.SPARK], CHARACTERS[Id.EMBER], CHARACTERS[Id.VOLT]]


static func get_by_id(id: String) -> Dictionary:
	for key: Id in CHARACTERS:
		if CHARACTERS[key]["id"] == id:
			return CHARACTERS[key]
	return CHARACTERS[Id.SPARK]


static func apply_to_player(player: PlayerSpark, char_id: String) -> void:
	var data: Dictionary = get_by_id(char_id)
	player.mods["speed_mult"] = float(data["speed_mult"])
	player.mods["dmg_mult"] = float(data["damage_mult"])
	player.mods["rate_mult"] = float(data["rate_mult"])
	RunState.max_hp = int(data["hp"])
	RunState.hp = int(data["hp"])
