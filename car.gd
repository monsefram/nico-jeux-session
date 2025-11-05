# scripts/Car.gd — Godot 5 (grip, pente, downforce)
extends RigidBody2D

# --- Propulsion & grip ---
@export var ground_thrust: float = 3400.0   # poussée le long de la pente
@export var max_speed: float = 1200.0       # vitesse linéaire max (px/s)
@export var ground_grip: float = 16_000.0   # “frein” latéral pour coller à la pente
@export var downforce: float = 1400.0       # force vers la normale (colle au sol)

# --- Alignement & stabilité ---
@export var align_strength: float = 14.0    # aligne la voiture à la pente au sol
@export var air_aim_strength: float = 9.0   # vise droite/gauche en l’air
@export var max_air_ang_vel: float = 18.0   # limite toupie

# --- Flips (en l’air) ---
@export var flip_torque: float = 5600.0

# --- Damping dynamique ---
@export var idle_linear_damp: float = 8.0
@export var drive_linear_damp: float = 1.1

@onready var rc: RayCast2D = $RayCast2D  # Enabled=true, target_position vers le bas (~0,28)

var _input_dir: int = 0  # -1 gauche, +1 droite, 0 rien

func _physics_process(delta: float) -> void:
	var grounded: bool = rc.is_colliding()

	# input
	_input_dir = 0
	if Input.is_action_pressed("ui_right"):
		_input_dir += 1
	if Input.is_action_pressed("ui_left"):
		_input_dir -= 1

	# damping adaptatif
	if _input_dir == 0:
		linear_damp = idle_linear_damp
	else:
		linear_damp = drive_linear_damp

	if grounded:
		var n := rc.get_collision_normal().normalized()    # normale du sol
		_drive_on_slope(n, delta)                          # pousse le long de la pente
		_stick_to_slope(n, delta)                          # downforce + anti-glisse
		_align_with_slope(n, delta)                        # oriente la voiture
	else:
		_flip_in_air()
		_aim_in_air()

	_cap_speed()


# ----- Propulsion le long de la pente -----
func _drive_on_slope(n: Vector2, delta: float) -> void:
	if _input_dir == 0:
		return

	# tangente = rotation 90° de la normale
	var t := Vector2(-n.y, n.x).normalized()

	# on veut que → avance vers +X et ← vers -X (quel que soit le sens de t)
	if t.dot(Vector2.RIGHT) < 0.0:
		t = -t

	var thrust_vec := t * ground_thrust * float(_input_dir)
	apply_central_force(thrust_vec)


# ----- Colle au sol + anti-glisse latérale -----
func _stick_to_slope(n: Vector2, delta: float) -> void:
	# Downforce: appuie la voiture sur le sol (réduit les rebonds)
	apply_central_force(n * downforce)

	# Anti-glisse: enlève la composante de vitesse qui “décroche” de la pente
	# Décompose la vitesse en composante tangentielle et normale
	var t := Vector2(-n.y, n.x).normalized()
	if t.dot(Vector2.RIGHT) < 0.0:
		t = -t

	var v := linear_velocity
	var v_tan := t * v.dot(t)      # composante le long de la pente
	var v_norm := n * v.dot(n)     # composante perpendiculaire (glisse)

	# applique une force opposée à la glisse
	var anti_slide := -v_norm * ground_grip * delta
	apply_central_force(anti_slide)


# ----- Aligne la carrosserie avec la pente -----
func _align_with_slope(n: Vector2, delta: float) -> void:
	# angle cible = angle de la tangente
	var t := Vector2(-n.y, n.x)
	if t.dot(Vector2.RIGHT) < 0.0:
		t = -t
	var target_rot := t.angle()

	var err := wrapf(target_rot - rotation, -PI, PI)
	apply_torque(err * align_strength)


# ----- Flips & visée en l'air -----
func _flip_in_air() -> void:
	if _input_dir == 0:
		return
	var torque_val := 0.0
	if _input_dir > 0:
		torque_val = -flip_torque  # → frontflip
	else:
		torque_val = +flip_torque  # ← backflip
	apply_torque(torque_val)

	if abs(angular_velocity) > max_air_ang_vel:
		angular_velocity = sign(angular_velocity) * max_air_ang_vel


func _aim_in_air() -> void:
	if _input_dir == 0:
		return
	var target_rot := 0.0
	if _input_dir > 0:
		target_rot = 0.0   # vise la droite
	else:
		target_rot = PI    # vise la gauche
	var err := wrapf(target_rot - rotation, -PI, PI)
	apply_torque(err * air_aim_strength)


# ----- Limiteur de vitesse -----
func _cap_speed() -> void:
	if max_speed <= 0.0:
		return
	var v := linear_velocity
	if v.length() > max_speed:
		linear_velocity = v.normalized() * max_speed
