extends RigidBody2D

var wheels: Array[RigidBody2D] = []

@export var speed: float = 5000.0
@export var max_speed: float = 20.0      # rad/s pour la roue
@export var body_torque: float = 1000.0  # couple appliqué au châssis en avant
@export var body_torque_rev: float = 1000.0  # couple pour arrière

func _ready() -> void:
	wheels.clear()
	for n in get_tree().get_nodes_in_group("wheel"):
		var rb := n as RigidBody2D
		if rb:
			wheels.append(rb)


func _physics_process(delta: float) -> void:
	var s := delta * 60.0

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
