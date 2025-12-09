extends Node

var is_muted := false

func is_on_arcade() -> bool:
	return OS.get_executable_path().to_lower().contains("retropie")
	
	
func manage_end_game() -> void:
	if is_on_arcade() :
		if Input.is_action_pressed("hotkey") and Input.is_action_pressed("quit"):
			get_tree().quit()
	else :
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()

func _process(_delta: float) -> void:
	manage_end_game()
	manage_mute()

func manage_mute() -> void:
	if Input.is_action_just_pressed("mute"):
		is_muted = !is_muted
		
		AudioServer.set_bus_mute(0, is_muted)
		
