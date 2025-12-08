extends Control


func _process(delta: float) -> void:
	var mouse_speed = 400
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_move = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		mouse_move.x += 1
	if Input.is_action_pressed("ui_left"):
		mouse_move.x -= 1
	if Input.is_action_pressed("ui_down"):
		mouse_move.y += 1
	if Input.is_action_pressed("ui_up"):
		mouse_move.y -= 1

	mouse_pos += mouse_move * mouse_speed * delta

	# 🔥 LIMITER À L'ÉCRAN (OBLIGATOIRE)
	var viewport_size = get_viewport().get_visible_rect().size
	mouse_pos.x = clamp(mouse_pos.x, 0.0, viewport_size.x - 1)
	mouse_pos.y = clamp(mouse_pos.y, 0.0, viewport_size.y - 1)

	Input.warp_mouse(mouse_pos)

func _unhandled_input(event: InputEvent) -> void:
	# Ici tu déclenches le "clic" avec une action (Enter / bouton manette)
	if Input.is_action_just_pressed("ui_accept"):
		_fake_mouse_click()

func _fake_mouse_click() -> void:
	var pos := get_viewport().get_mouse_position()

	var ev_down := InputEventMouseButton.new()
	ev_down.button_index = MOUSE_BUTTON_LEFT
	ev_down.pressed = true
	ev_down.position = pos
	Input.parse_input_event(ev_down)

	var ev_up := InputEventMouseButton.new()
	ev_up.button_index = MOUSE_BUTTON_LEFT
	ev_up.pressed = false
	ev_up.position = pos
	Input.parse_input_event(ev_up)


func _on_lvl_1_button_down() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_lvl_2_button_down() -> void:
	get_tree().change_scene_to_file("res://level_2.tscn")


func _on_lvl_3_button_down() -> void:
	get_tree().change_scene_to_file("res://level_3.tscn")


func _on_back_button_down() -> void:
	get_tree().change_scene_to_file("res://menu_principal.tscn")
