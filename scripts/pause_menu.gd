extends Control
#@onready var optionsMenu = preload("res://options_menu.tscn")
@onready var main_button: VBoxContainer = $PanelContainer/MainButton
@onready var settings: VBoxContainer = $PanelContainer/Settings



func _ready():
	$AnimationPlayer.play("RESET")
	main_button.visible = true
	settings.visible = false

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()


func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()

func _process(_delta):
	testEsc()


func _on_restart_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://levels.tscn")


func _on_settings_pressed() -> void:
	main_button.visible = false
	settings.visible = true
	


func _on_button_pressed() -> void:
	main_button.visible = true
	settings.visible = false
