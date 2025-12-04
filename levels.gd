extends Control

func _on_lvl_1_button_down() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_lvl_2_button_down() -> void:
	get_tree().change_scene_to_file("res://level_2.tscn")


func _on_lvl_3_button_down() -> void:
	get_tree().change_scene_to_file("res://level_3.tscn")


func _on_back_button_down() -> void:
	get_tree().change_scene_to_file("res://menu_principal.tscn")
