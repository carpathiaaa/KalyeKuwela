extends Control

@export var pointer_is_over_target : bool

func _on_TimedClickBar_pressed():
	print("callback")
	if pointer_is_over_target:
		print("Yes!")
	else:
		print("No")
