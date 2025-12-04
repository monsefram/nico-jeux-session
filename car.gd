extends RigidBody2D

var wheels: Array[RigidBody2D] = []

var hud

@export var speed: float = 10000.0
@export var max_speed: float = 27.0
@export var body_torque: float = -13000.0
@export var body_torque_rev: float = -13000.0

@onready var vroom: AudioStreamPlayer2D = $Vroom


# ---- Respawn ----
@export var fall_limit_y: float = 3500.0
var spawn_position: Vector2
var spawn_rotation: float = 0.0

# NOUVEAU : spawn par scène
func _set_spawn_from_scene():
	var spawns = get_tree().get_nodes_in_group("spawn")
	if spawns.size() > 0:
		var sp = spawns[0]
		spawn_position = sp.global_position
		spawn_rotation = sp.global_rotation


func _ready() -> void:
	hud = get_tree().get_first_node_in_group("hud")

	wheels.clear()
	for n in get_tree().get_nodes_in_group("wheel"):
		var rb := n as RigidBody2D
		if rb:
			wheels.append(rb)

	# Enregistre la position de départ comme point de respawn (si pas de SpawnPoint)
	spawn_position = global_position
	spawn_rotation = global_rotation

	_set_spawn_from_scene()


func _physics_process(delta: float) -> void:
	var s := delta * 60.0

	var accelerating := false

	if Input.is_action_pressed("ui_right"):
		accelerating = true
		apply_torque_impulse(body_torque * s)
		for w in wheels:
			if w.angular_velocity < max_speed:
				w.apply_torque_impulse(speed * s)

	elif Input.is_action_pressed("ui_left"):
		accelerating = true
		apply_torque_impulse(-body_torque_rev * s)
		for w in wheels:
			if w.angular_velocity > -max_speed:
				w.apply_torque_impulse(-speed * s)

	# 🔊 --- SON MOTEUR ---
	if accelerating:
		if not vroom.playing:
			vroom.play()
		vroom.pitch_scale = lerp(vroom.pitch_scale, 1.8, delta * 5)
	else:
		vroom.pitch_scale = max(0.8, vroom.pitch_scale - delta * 2)
		if vroom.pitch_scale <= 0.81:
			vroom.stop()

	# Respawn si tombe
	if global_position.y > fall_limit_y:
		_respawn()

	var speed_mps = linear_velocity.length()
	var speed_kmh = speed_mps * 0.03

	if hud:
		var speedometer = hud.get_node("Speedometer")
		speedometer.update_speed(speed_kmh)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		_respawn()


func _respawn() -> void:
	global_position = spawn_position
	global_rotation = spawn_rotation
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
