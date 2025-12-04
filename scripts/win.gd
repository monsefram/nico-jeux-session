extends CanvasLayer


func _ready() -> void:
	self.hide()


func win():
	self.show()
	get_tree().paused = true
	
func _on_mainmenu_pressed() -> void:
	get_tree().paused = false

	get_tree().change_scene_to_file("res://menu_principal.tscn")


func _on_levels_pressed() -> void:
	get_tree().paused = false

	get_tree().change_scene_to_file("res://levels.tscn")
