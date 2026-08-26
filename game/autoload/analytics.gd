extends Node
## Event pipeline stub — GameAnalytics + Firebase SDKs wire in during their own
## milestone; until then events print to console/logcat so every seam already
## exists. Gameplay code calls design_event() only — never an SDK directly.

var _session_events := 0


func design_event(event_name: String, params: Dictionary = {}) -> void:
	_session_events += 1
	print("[analytics] #%d %s %s" % [_session_events, event_name, params])


func session_event_count() -> int:
	return _session_events
