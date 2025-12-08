extends Node

var is_muted := false


func manage_end_game() -> void:
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()

func _process(_delta: float) -> void:
	manage_end_game()
	manage_mute()

func manage_mute() -> void:
	if Input.is_action_just_pressed("mute"):
		is_muted = !is_muted
		
		AudioServer.set_bus_mute(0, is_muted)
		
