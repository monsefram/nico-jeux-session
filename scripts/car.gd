extends RigidBody2D

var wheels: Array[RigidBody2D] = []
var hud

@export var speed: float = 10000.0
@export var max_speed: float = 27.0
@export var body_torque: float = -13000.0
@export var body_torque_rev: float = -13000.0

@onready var vroom: AudioStreamPlayer2D = $Vroom
@onready var rewind_fx: AudioStreamPlayer2D = $RewindSound     

# ---- Respawn ----
@export var fall_limit_y: float = 3500.0
var spawn_position: Vector2
var spawn_rotation: float = 0.0

# ---- REWIND SYSTEM ----
var record_time := 8.0
var buffer := []
var max_frames := 60 * 8
var rewinding := false

# Cooldown de rewind
var rewind_cooldown := 0.0
var rewind_delay := 10.0       

# ---- Spawn par scène ----
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

	spawn_position = global_position
	spawn_rotation = global_rotation
	_set_spawn_from_scene()

	StateMachine.set_state(StateMachine.STATE_NORMAL)



# ---- Enregistrer l'état ----
func _record_state():
	buffer.append({
		"pos": global_position,
		"rot": global_rotation,
		"vel": linear_velocity,
		"ang": angular_velocity
	})
	if buffer.size() > max_frames:
		buffer.pop_front()


# ---- Rewind ----
func _rewind(delta):
	if buffer.size() == 0:
		_stop_rewind()
		return

	var state = buffer.pop_back()
	global_position = state["pos"]
	global_rotation = state["rot"]
	linear_velocity = state["vel"]
	angular_velocity = state["ang"]


func _start_rewind():
	if rewind_cooldown > 0:
		return

	rewinding = true
	rewind_cooldown = rewind_delay

	StateMachine.set_state(StateMachine.STATE_REWIND)

	if rewind_fx:
		rewind_fx.play()


func _stop_rewind():
	rewinding = false
	StateMachine.set_state(StateMachine.STATE_NORMAL)



func _physics_process(delta: float) -> void:
	var s := delta * 60.0

	# Cooldown
	if rewind_cooldown > 0:
		rewind_cooldown -= delta

	# --- Activation du rewind ---
	if Input.is_action_pressed("back"):
		if not rewinding:
			_start_rewind()
	else:
		if rewinding:
			_stop_rewind()

	# --- Mode rewind avec machine à état ---
	if StateMachine.is_state(StateMachine.STATE_REWIND):
		_rewind(delta)
		return
	else:
		_record_state()


	# --- Contrôles (inchangés) ---
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

	# --- Son moteur ---
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

	# Vitesse HUD
	var speed_mps = linear_velocity.length()
	var speed_kmh = speed_mps * 0.03
	if hud:
		var speedometer = hud.get_node("Speedometer")
		speedometer.update_speed(speed_kmh)



func _respawn() -> void:
	global_position = spawn_position
	global_rotation = spawn_rotation
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	buffer.clear()
	_stop_rewind()

	StateMachine.set_state(StateMachine.STATE_NORMAL)
