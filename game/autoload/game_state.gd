extends Node
## Global state machine — GDD §12.3: BOOT → MENU → RUN → LEVELUP → RESULTS → META.

signal state_changed(from: State, to: State)

enum State { BOOT, MENU, RUN, LEVELUP, RESULTS, META }

var current: State = State.BOOT


func change_state(to: State) -> void:
	if to == current:
		return
	var from := current
	current = to
	Analytics.design_event("state_changed", {"from": State.keys()[from], "to": State.keys()[to]})
	state_changed.emit(from, to)
