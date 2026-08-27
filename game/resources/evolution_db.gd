class_name EvolutionDb
extends RefCounted
## Weapon evolutions — combine 2 max-level weapons into a super weapon.
## Triggered via auto-pick when both component weapons are owned at max level.

const EVOLUTIONS := {
	"plasma_storm": {
		"title": "⚡ PLASMA STORM",
		"desc": "Homing orbs that explode on contact",
		"components": ["pulse", "orbit"],
		"color": Color(0.0, 0.94, 1.0),
		"interval": 0.35,
		"damage": 3,
		"radius": 80.0,
	},
	"thunder_cannon": {
		"title": "⚡ THUNDER CANNON",
		"desc": "Massive bolts that chain to nearby enemies",
		"components": ["pulse", "nova"],
		"color": Color(1.0, 0.84, 0.0),
		"interval": 0.8,
		"damage": 8,
		"chain": 5,
		"chain_range": 200.0,
	},
	"solar_flare": {
		"title": "☀️ SOLAR FLARE",
		"desc": "Orbiting blades that create shockwaves",
		"components": ["orbit", "nova"],
		"color": Color(1.0, 0.45, 0.1),
		"interval": 0.3,
		"damage": 4,
		"shockwave_radius": 100.0,
	},
	"storm_nova": {
		"title": "❄️ STORM NOVA",
		"desc": "Area freeze + lightning damage",
		"components": ["frost", "lightning"],
		"color": Color(0.4, 0.8, 1.0),
		"interval": 1.5,
		"damage": 6,
		"radius": 180.0,
		"slow": 0.7,
		"slow_dur": 4.0,
		"chain": 3,
		"chain_range": 150.0,
	},
	"plasma_trail": {
		"title": "🔥 PLASMA TRAIL",
		"desc": "Fire trail that chains to enemies",
		"components": ["flame", "lightning"],
		"color": Color(1.0, 0.55, 0.0),
		"interval": 0.3,
		"damage": 3,
		"chain": 2,
		"chain_range": 120.0,
		"patch_lifetime": 4.0,
	},
}


static func check_available(owned_guns: Array, gun_lv: Dictionary) -> Array:
	"""Return list of available evolutions based on owned max-level weapons."""
	var available := []
	for evo_id: String in EVOLUTIONS:
		var evo: Dictionary = EVOLUTIONS[evo_id]
		var comps: Array = evo["components"]
		var has_all := true
		for comp: String in comps:
			if not owned_guns.has(comp) or int(gun_lv.get(comp, 1)) < 5:
				has_all = false
				break
		if has_all:
			available.append(evo_id)
	return available


static func get_recipe(evo_id: String) -> Dictionary:
	return EVOLUTIONS.get(evo_id, {})
