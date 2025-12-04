extends Control


func _on_startbtn_button_down() -> void:
	get_tree().change_scene_to_file("res://levels.tscn")

func _on_quitbtn_button_down() -> void:
	get_tree().quit()
