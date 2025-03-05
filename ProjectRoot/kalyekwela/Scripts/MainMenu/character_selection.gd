extends Control

func _process(delta) -> void:
	match GlobalData.PlayerSelect:
		0:
			get_node('AvatarIcon').play('Juan')
		1:
			get_node('AvatarIcon').play('Maria')
		2:
			get_node('AvatarIcon').play('Antonio')
		3:
			get_node('AvatarIcon').play('Carlo')
		4:
			get_node('AvatarIcon').play('Reyna')
		5:
			get_node('AvatarIcon').play('Tala')	
		

func _on_right_arrow_pressed() -> void:
	if GlobalData.PlayerSelect < 6:
		GlobalData.PlayerSelect += 1


func _on_left_arrow_pressed() -> void:
	if GlobalData.PlayerSelect > 0:
		GlobalData.PlayerSelect -= 1
