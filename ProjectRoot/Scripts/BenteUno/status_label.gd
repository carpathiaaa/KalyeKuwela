extends Label

func update_status(is_chaser: bool):
	text = "Chaser" if is_chaser else "Runner"
