# scripts/Car.gd — Godot 5 (sans opérateur ?:)
extends RigidBody2D

@export var ground_force: float = 2200.0
@export var max_speed: float = 900.0
@export var ground_turn_assist: float = 6.0

@export var flip_torque: float = 5200.0
@export var max_air_ang_vel: float = 18.0
@export var air_aim_strength: float = 9.0

@export var idle_linear_damp: float = 8.0
@export var drive_linear_damp: float = 1.2

@onready var rc: RayCast2D = $RayCast2D

var _input_dir: int = 0  # -1 = gauche, +1 = droite, 0 = rien

func _physics_process(delta: float) -> void:
	var grounded: bool = rc.is_colliding()

	# lecture inputs (flèches)
	var right_strength := Input.get_action_strength("ui_right")
	var left_strength := Input.get_action_strength("ui_left")
	_input_dir = 0
	if right_strength > 0.0:
		_input_dir += 1
	if left_strength > 0.0:
		_input_dir -= 1

	# damping adaptatif (remplace: linear_damp = _input_dir == 0 ? idle : drive)
	if _input_dir == 0:
		linear_damp = idle_linear_damp
	else:
		linear_damp = drive_linear_damp

	if grounded:
		_drive_on_ground()
		_aim_on_ground()
	else:
		_flip_in_air()
		_aim_in_air()

	_cap_speed()


func _drive_on_ground() -> void:
	if _input_dir == 0:
		return
	# force strict horizontale (jeu gauche/droite)
	var f := Vector2(_input_dir * ground_force, 0.0)
	apply_central_force(f)

	# auto “level” léger au sol vers 0 rad
	var target_rot := 0.0
	var err := wrapf(target_rot - rotation, -PI, PI)
	apply_torque(err * ground_turn_assist * ground_force * 0.001)


func _aim_on_ground() -> void:
	var target_rot := 0.0
	var err := wrapf(target_rot - rotation, -PI, PI)
	apply_torque(err * ground_turn_assist)


func _flip_in_air() -> void:
	if _input_dir == 0:
		return
	# → = frontflip (horaire → couple négatif), ← = backflip (anti-horaire → positif)
	var torque_val := 0.0
	if _input_dir > 0:
		torque_val = -flip_torque
	else:
		torque_val = +flip_torque
	apply_torque(torque_val)

	if abs(angular_velocity) > max_air_ang_vel:
		angular_velocity = sign(angular_velocity) * max_air_ang_vel


func _aim_in_air() -> void:
	if _input_dir == 0:
		return
	# vise la droite si →, la gauche si ← (remplace: _input_dir > 0 ? 0.0 : PI)
	var target_rot := 0.0
	if _input_dir > 0:
		target_rot = 0.0
	else:
		target_rot = PI
	var err := wrapf(target_rot - rotation, -PI, PI)
	apply_torque(err * air_aim_strength)


func _cap_speed() -> void:
	if max_speed <= 0.0:
		return
	var v := linear_velocity
	if v.length() > max_speed:
		linear_velocity = v.normalized() * max_speed
