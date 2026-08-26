extends Node
## AdsManager abstraction — GDD §12.3: one interface, swappable backend.
## The AdMob plugin (Google test IDs in dev) plugs in behind these methods;
## gameplay code must stay SDK-agnostic forever.

func is_rewarded_ready(_placement: String) -> bool:
	return false


func show_rewarded(placement: String, callback: Callable) -> void:
	# callback(success: bool) — false = "no reward available"; UI must handle it.
	print("[ads] rewarded '%s' requested — no SDK wired in dev builds" % placement)
	callback.call(false)


func show_interstitial(_placement: String) -> void:
	pass  # frequency-capping and pacing rules arrive with the real adapter
