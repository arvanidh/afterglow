class_name CardDb
extends RefCounted
## Level-up draft deck (§5.5 build-crafting). Pure data — no scene deps.
## Cards come in three kinds: WEAPON_UP (owned gun +1 level), WEAPON_NEW
## (unlock one of the other two guns), PASSIVE (stackable stat mods).

enum Rarity { COMMON, UNCOMMON, RARE, EPIC }

const RARITY_COLORS := {
	Rarity.COMMON: Color(0.85, 0.9, 1.0),
	Rarity.UNCOMMON: Color(0.35, 1.0, 0.55),
	Rarity.RARE: Color(1.0, 0.35, 0.75),
	Rarity.EPIC: Color(1.0, 0.72, 0.0),
}
const RARITY_WEIGHTS := [60.0, 25.0, 11.0, 4.0]

const WEAPON_MAX_LV := 5

# Passive stacks: id -> max copies per run.
const PASSIVE_MAX := {
	"swift": 3, "overclock": 3, "focus": 3, "magnet": 3,
	"vitality": 5, "ghost": 2, "twin": 2, "sigil": 2,
}

const PASSIVE_DEFS := {
	"swift": {"title": "Swift Boots", "desc": "+10% move speed", "rarity": Rarity.COMMON},
	"overclock": {"title": "Overclock", "desc": "+14% fire rate", "rarity": Rarity.COMMON},
	"focus": {"title": "Focus Lens", "desc": "+20% damage", "rarity": Rarity.UNCOMMON},
	"magnet": {"title": "Magnet Core", "desc": "+45% pickup reach", "rarity": Rarity.COMMON},
	"vitality": {"title": "Vital Bloom", "desc": "+1 max HP · heal 1", "rarity": Rarity.UNCOMMON},
	"ghost": {"title": "Ghost Step", "desc": "dash recharges 22% faster", "rarity": Rarity.RARE},
	"twin": {"title": "Twin Filament", "desc": "bolts may split in two", "rarity": Rarity.RARE},
	"sigil": {"title": "Shard Sigil", "desc": "+15% shard payout", "rarity": Rarity.EPIC},
}

const WEAPON_UP_DEFS := {
	"pulse": {"title": "Pulse Bolt+", "desc": "denser, meaner bolts"},
	"orbit": {"title": "Orbit Blades+", "desc": "+1 blade, wider arc"},
	"nova": {"title": "Nova Burst+", "desc": "bigger boom, shorter fuse"},
	"lightning": {"title": "Lightning+", "desc": "more chains, more pain"},
	"frost": {"title": "Frost Nova+", "desc": "bigger freeze, longer slow"},
	"flame": {"title": "Flame Trail+", "desc": "hotter fire, bigger patches"},
}

const WEAPON_NEW_DEFS := {
	"orbit": {"title": "ORBIT BLADES", "desc": "satellites orbit you — your body is the aim", "rarity": Rarity.UNCOMMON},
	"nova": {"title": "NOVA BURST", "desc": "radial shockwave that shoves shadows back", "rarity": Rarity.UNCOMMON},
	"lightning": {"title": "LIGHTNING CHAIN", "desc": "bolts that chain to nearby enemies", "rarity": Rarity.UNCOMMON},
	"frost": {"title": "FROST NOVA", "desc": "area damage + slow around you", "rarity": Rarity.UNCOMMON},
	"flame": {"title": "FLAME TRAIL", "desc": "leave burning ground while you move", "rarity": Rarity.UNCOMMON},
}

# Hybrid weapon crafting recipes: two parent weapons → one hybrid
const HYBRID_RECIPES := {
	"steam_cloud": {"parents": ["frost", "flame"], "title": "STEAM CLOUD", "desc": "Frost + Flame = lingering cloud that SLOWS + BURNS", "color": Color(0.7, 1.0, 0.8)},
	"tesla_field": {"parents": ["lightning", "orbit"], "title": "TESLA FIELD", "desc": "Lightning + Orbit = orbiting bolts that CHAIN", "color": Color(0.4, 0.7, 1.0)},
	"impulse_wave": {"parents": ["pulse", "nova"], "title": "IMPULSE WAVE", "desc": "Pulse + Nova = piercing wave hits ALL enemies", "color": Color(1.0, 0.8, 0.2)},
}

static func get_available_crafts(owned_guns: Array) -> Array:
	# Returns list of hybrid recipes that can be crafted with current weapons
	var crafts: Array = []
	for hybrid_id: String in HYBRID_RECIPES:
		var recipe: Dictionary = HYBRID_RECIPES[hybrid_id]
		var parents: Array = recipe["parents"]
		if owned_guns.has(parents[0]) and owned_guns.has(parents[1]):
			crafts.append({"id": hybrid_id, "title": recipe["title"], "desc": recipe["desc"], "color": recipe["color"], "parents": parents})
	return crafts


## Builds three distinct draft choices from what the run owns so far.
## owned_guns: Array[String] e.g. ["pulse"]; gun_lv: Dictionary id->int;
## passives: Dictionary id->stacks; has_pulse: bool (twin requires Pulse Bolt).
static func draw_three(owned_guns: Array, gun_lv: Dictionary, passives: Dictionary, rng: RandomNumberGenerator) -> Array:
	var pool: Array = []
	for id: String in owned_guns:
		var lv: int = gun_lv.get(id, 1)
		if lv < WEAPON_MAX_LV:
			pool.append({"kind": "weapon_up", "target": id, "rarity": _gun_rarity(lv)})
	for id: String in WEAPON_NEW_DEFS:
		if not owned_guns.has(id):
			pool.append({"kind": "weapon_new", "target": id, "rarity": WEAPON_NEW_DEFS[id]["rarity"]})
	for id: String in PASSIVE_DEFS:
		if int(passives.get(id, 0)) < int(PASSIVE_MAX[id]):
			if id != "twin" or owned_guns.has("pulse"):
				pool.append({"kind": "passive", "target": id, "rarity": PASSIVE_DEFS[id]["rarity"]})
	pool.append({"kind": "passive", "target": "vitality_fallback", "rarity": Rarity.COMMON})

	var picks: Array = []
	while picks.size() < 3 and not pool.is_empty():
		var total := 0.0
		for c: Dictionary in pool:
			total += RARITY_WEIGHTS[c["rarity"]]
		var roll := rng.randf() * total
		var chosen: Dictionary = pool[0]
		for c: Dictionary in pool:
			roll -= RARITY_WEIGHTS[c["rarity"]]
			if roll <= 0.0:
				chosen = c
				break
		pool.erase(chosen)
		picks.append(_decorate(chosen))
	return picks


static func _gun_rarity(lv: int) -> int:
	return Rarity.COMMON if lv < 3 else Rarity.UNCOMMON


static func _decorate(card: Dictionary) -> Dictionary:
	match String(card["kind"]):
		"weapon_up":
			var d: Dictionary = WEAPON_UP_DEFS[card["target"]]
			card["title"] = d["title"]
			card["desc"] = d["desc"]
		"weapon_new":
			var d: Dictionary = WEAPON_NEW_DEFS[card["target"]]
			card["title"] = d["title"]
			card["desc"] = d["desc"]
		_:
			var pid := String(card["target"])
			if pid == "vitality_fallback":
				card["target"] = "vitality"
				card["title"] = "Vital Bloom"
				card["desc"] = "+1 max HP · heal 1"
				card["rarity"] = Rarity.COMMON
			else:
				var d: Dictionary = PASSIVE_DEFS[pid]
				card["title"] = d["title"]
				card["desc"] = d["desc"]
	return card
