extends RigidBody2D

var wheels: Array[RigidBody2D] = []

@export var speed: float = 8000.0
@export var max_speed: float = 20.0      # rad/s pour la roue
@export var body_torque: float = 1000.0  # couple appliqué au châssis en avant
@export var body_torque_rev: float = 1000.0  # couple pour arrière

# ---- Respawn ----
@export var fall_limit_y: float = 2400.0    # quand la voiture tombe trop bas
var spawn_position: Vector2
var spawn_rotation: float = 0.0

func _ready() -> void:
	wheels.clear()
	for n in get_tree().get_nodes_in_group("wheel"):
		var rb := n as RigidBody2D
		if rb:
			wheels.append(rb)

	# Enregistre la position de départ comme point de respawn
	spawn_position = global_position
	spawn_rotation = global_rotation


func _physics_process(delta: float) -> void:
	var s := delta * 60.0

	# --- Contrôles ---
	if Input.is_action_pressed("ui_right"):
		apply_torque_impulse(body_torque * s)
		for w in wheels:
			if w.angular_velocity < max_speed:
				w.apply_torque_impulse(speed * s)

	elif Input.is_action_pressed("ui_left"):
		apply_torque_impulse(-body_torque_rev * s)
		for w in wheels:
			if w.angular_velocity > -max_speed:
				w.apply_torque_impulse(-speed * s)

	# --- Respawn automatique s'il tombe ---
	if global_position.y > fall_limit_y:
		_respawn()


func _unhandled_input(event: InputEvent) -> void:
	# Permet au joueur de respawn manuellement avec "R" ou "Entrée"
	if event.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		_respawn()


func _respawn() -> void:
	global_position = spawn_position
	global_rotation = spawn_rotation
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
